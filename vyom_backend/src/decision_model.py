import os
from typing import Dict, List, Optional, Union
from pydantic import BaseModel, Field
from fastapi import HTTPException, Depends
from supabase import create_client, Client
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime, timedelta

# Data models
class QueryInput(BaseModel):
    query_id: str
    created: str = None
    updated: str = None
    estimated_time: str = None
    activity_logs: List = Field(default_factory=list)
    subtype: str = None
    cust_id: str
    title: str
    employee: str = None
    date_time: str = None
    department_name: str
    description: str
    query_level: int = Field(ge=1, le=3)  # 1-3 complexity
    priority_level: int = Field(ge=1, le=10)  # 1-10 priority
    transcript_bkturl: str = None
    additional_details: Dict = Field(default_factory=dict)
    chat_id: str = None
    appointment_id: str = None
    status: str = "Active"
    location: str = None
    language: str = "English"
    query_sentiment: str = "Positive"
    categories: str = None

class AssignmentResponse(BaseModel):
    query_id: str
    assigned_employee_id: str
    expected_response_time: str
    priority_score: float
    historical_match_used: bool
    department: str
    sub_branch: str = None
    category: str = None

# Supabase client setup function
def get_supabase_client() -> Client:
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_KEY")
    
    if not supabase_url or not supabase_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    
    return create_client(supabase_url, supabase_key)

class BankingQueryAssignmentSystem:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        
        # Banking domain structure
        self.banking_map = {
            "Credit": {
                "sub_branches": [
                    "Retail Loans",
                    "Corporate Loans",
                    "Credit Cards",
                    "Mortgage & Secured Loans",
                    "Microfinance & Agricultural Loans"
                ],
                "categories": [
                    "Home Loan",
                    "Car Loan",
                    "Personal Loan",
                    "Education Loan",
                    "Loan Against Property",
                    "Working Capital Loan",
                    "Credit Limit Increase",
                    "Reward Points Inquiry"
                ]
            },
            "General Banking": {
                "sub_branches": [
                    "Accounts & Deposits",
                    "Transactions & Payments",
                    "Cards & Banking Services",
                    "KYC & Documentation",
                    "Banking Tech & Digital Services"
                ],
                "categories": [
                    "Savings Account",
                    "Current Account",
                    "Fixed Deposit",
                    "Recurring Deposit",
                    "NEFT/RTGS/IMPS Issue",
                    "Debit Card Activation",
                    "Lost/Stolen Card",
                    "Net Banking Login Issue",
                    "Mobile Banking Issue"
                ]
            },
            "Forex": {
                "sub_branches": [
                    "Currency Exchange",
                    "International Transactions",
                    "Trade Finance",
                    "Foreign Investments & NRI Banking"
                ],
                "categories": [
                    "Foreign Exchange Rates Inquiry",
                    "Cash Currency Exchange",
                    "SWIFT Transfer",
                    "Letter of Credit",
                    "Bank Guarantee",
                    "NRE/NRO Account Opening",
                    "Repatriation of Funds"
                ]
            },
            "Customer Support": {
                "sub_branches": [
                    "General Inquiries",
                    "Complaints & Feedback",
                    "Technical Support",
                    "Account Assistance"
                ],
                "categories": [
                    "Account Information",
                    "Service Feedback",
                    "Technical Issue",
                    "Fraud Reporting",
                    "Dispute Resolution"
                ]
            }
        }
        
        # Create category to department and sub-branch mappings
        self.category_map = self._build_category_map()
        
    def _build_category_map(self):
        """Build mapping from category to department and sub-branch"""
        category_map = {}
        for dept, details in self.banking_map.items():
            for category in details["categories"]:
                # Find most likely sub_branch for this category
                most_likely_sub_branch = self._get_likely_sub_branch(category, details["sub_branches"])
                category_map[category] = {
                    "department": dept,
                    "sub_branch": most_likely_sub_branch
                }
        return category_map
    
    def _get_likely_sub_branch(self, category, sub_branches):
        """Helper method to determine most appropriate sub-branch for a category"""
        # Simple implementation - can be enhanced with more sophisticated matching
        return sub_branches[0]

    async def load_employees(self):
        """Load employee data with experience levels and current workload"""
        # Fetch employees with their basic information
        employees_response = await self.supabase.table("employee").select("*").execute()
        
        if not employees_response.data:
            raise HTTPException(status_code=404, detail="No employees found in database")
        
        employees_df = pd.DataFrame(employees_response.data)
        
        # Fetch active appointments to calculate workload
        appointments_response = await self.supabase.table("appointment").select("*").eq("status", "active").execute()
        
        # Process appointment data for employee workload
        if appointments_response.data:
            appointments_df = pd.DataFrame(appointments_response.data)
            workload = appointments_df.groupby('employee_id').size().reset_index(name='current_workload')
            employees_df = pd.merge(employees_df, workload, on='employee_id', how='left')
        else:
            employees_df['current_workload'] = 0
            
        # Calculate average ratings from past appointments
        ratings_response = await self.supabase.table("appointment").select("employee_id,rating").not_.is_("rating", "null").execute()
        
        if ratings_response.data:
            ratings_df = pd.DataFrame(ratings_response.data)
            avg_ratings = ratings_df.groupby('employee_id')['rating'].mean().reset_index(name='avg_rating')
            employees_df = pd.merge(employees_df, avg_ratings, on='employee_id', how='left')
        else:
            employees_df['avg_rating'] = 4.0  # Default rating
            
        # Fill NAs with defaults
        employees_df['current_workload'].fillna(0, inplace=True)
        employees_df['avg_rating'].fillna(4.0, inplace=True)
        
        return employees_df
    
    async def load_customer_history(self, cust_id):
        """Load history of customer interactions with employees"""
        history_response = await self.supabase.table("appointment").select("*").eq("cust_id", cust_id).execute()
        
        if not history_response.data:
            return pd.DataFrame()
            
        history_df = pd.DataFrame(history_response.data)
        
        # Calculate satisfaction and interaction counts
        customer_history = history_df.groupby(['cust_id', 'employee_id']).agg(
            satisfaction=('rating', 'mean'),
            interaction_count=('appointment_id', 'count'),
            max_rating=('rating', 'max')
        ).reset_index()
        
        return customer_history
    
    async def find_historical_match(self, cust_id, dept, sub_branch):
        """Find employees with good history with this customer in same department"""
        history = await self.load_customer_history(cust_id)
        
        if history.empty:
            return None
            
        # Only consider employees with good ratings (> 4.0) and multiple interactions
        good_matches = history[(history['satisfaction'] >= 4.0) & 
                            (history['interaction_count'] >= 2)]
                            
        if good_matches.empty:
            return None
        
        # Load employee data
        employees = await self.load_employees()
        
        # For each good match, check if employee is in correct department/sub-branch
        best_match_id = None
        best_match_score = 0
        
        for _, match in good_matches.iterrows():
            emp_id = match['employee_id']
            emp_data = employees[employees['employee_id'] == emp_id]
            
            if emp_data.empty:
                continue
                
            emp_dept = emp_data['department_name'].iloc[0]
            emp_sub = emp_data['sub_branch'].iloc[0]
            
            # Calculate match score based on department fit and history
            match_score = match['satisfaction'] * 20  # Base: 0-100 scale
            
            # Department match is critical
            if emp_dept == dept:
                match_score += 50
            else:
                continue  # Must be in same department
                
            # Sub-branch match is preferred
            if emp_sub == sub_branch:
                match_score += 30
            
            if match_score > best_match_score:
                best_match_score = match_score
                best_match_id = emp_id
        
        return best_match_id
    
    def _get_query_sub_branch(self, query_data):
        """Determine the sub-branch for a query based on category and department"""
        category = query_data.get('categories')
        department = query_data.get('department_name')
        
        # Try to get from category map
        if category and category in self.category_map:
            return self.category_map[category]['sub_branch']
        
        # Fallback: use subtype to guess
        subtype = query_data.get('subtype')
        if department in self.banking_map:
            sub_branches = self.banking_map[department]["sub_branches"]
            
            # Simple keyword matching
            if subtype:
                for sb in sub_branches:
                    if subtype in sb or sb in subtype:
                        return sb
                    
            # Return first sub-branch as default
            return sub_branches[0]
        
        # Final fallback
        return "General Inquiries"
    
    async def get_customer_languages(self, cust_id):
        """Get customer preferred languages if available"""
        try:
            prefs_response = await self.supabase.table("customer_preferences").select("phone_language,preferred_language").eq("cust_id", cust_id).execute()
            
            if prefs_response.data:
                return [prefs_response.data[0].get('phone_language'), prefs_response.data[0].get('preferred_language')]
            return None
        except:
            # Table may not exist
            return None
    
    def get_wait_time(self, priority_score, query_level):
        """Calculate the maximum wait time based on priority score (0-100) and query complexity (1-3)"""
        # Base time based on priority (higher priority = less wait)
        if priority_score >= 80:
            base_time = "30 minutes"
            interval = "30 MINUTE"
        elif priority_score >= 60:
            base_time = "1 hour"
            interval = "1 HOUR"
        elif priority_score >= 40:
            base_time = "4 hours"
            interval = "4 HOUR"
        else:
            base_time = "24 hours"
            interval = "24 HOUR"
            
        # Adjust for complexity
        # Higher complexity may need more time regardless of priority
        if query_level == 3 and priority_score < 90:
            if base_time == "30 minutes":
                base_time = "1 hour"
                interval = "1 HOUR"
            elif base_time == "1 hour":
                base_time = "4 hours"
                interval = "4 HOUR"
                
        return f"within {base_time}", interval
    
    async def calculate_employee_suitability(self, query_data, employees, customer_languages=None):
        """Calculate suitability scores for employees based on query requirements"""
        # Extract query features
        query_level = query_data.get('query_level', 1)  # Complexity 1-3
        priority_level = query_data.get('priority_level', 5)  # Priority 1-10
        department = query_data.get('department_name')
        sub_branch = self._get_query_sub_branch(query_data)
        sentiment = query_data.get('query_sentiment', 'Positive')
        category = query_data.get('categories')
        query_language = query_data.get('language', 'English')
        
        # Calculate base suitability scores
        employees['suitability_score'] = 0
        
        # Department match (essential)
        employees.loc[employees['department_name'] == department, 'suitability_score'] += 50
        
        # Sub-branch match (very important)
        employees.loc[employees['sub_branch'] == sub_branch, 'suitability_score'] += 30
        
        # Experience level match
        for i, row in employees.iterrows():
            emp_level = row['employee_tier']
            
            # Map priority level (1-10) to appropriate employee tier match
            if priority_level >= 8:  # High priority
                if emp_level >= 4:  # Senior employees
                    employees.loc[i, 'suitability_score'] += 25
                elif emp_level == 3:  # Mid-level
                    employees.loc[i, 'suitability_score'] += 15
                else:  # Junior employees
                    employees.loc[i, 'suitability_score'] += 5
            elif priority_level >= 4:  # Medium priority
                if emp_level == 3:  # Mid-level employees best for medium priority
                    employees.loc[i, 'suitability_score'] += 25
                elif emp_level >= 4:  # Senior employees are good but overkill
                    employees.loc[i, 'suitability_score'] += 15
                else:  # Junior employees can handle but not ideal
                    employees.loc[i, 'suitability_score'] += 10
            else:  # Low priority
                if emp_level <= 2:  # Junior employees most appropriate
                    employees.loc[i, 'suitability_score'] += 25
                else:  # Higher level employees are excessive
                    employees.loc[i, 'suitability_score'] += 10
            
            # Query complexity match
            if query_level == 3:  # Complex query
                if emp_level >= 3:  # Need experienced employees
                    employees.loc[i, 'suitability_score'] += 20
            elif query_level == 2:  # Medium complexity
                if emp_level >= 2:  # Mid-level or higher
                    employees.loc[i, 'suitability_score'] += 15
            else:  # Simple query
                employees.loc[i, 'suitability_score'] += 10  # Any tier can handle
        
        # Language matching
        for i, row in employees.iterrows():
            # Check if employee speaks query language
            if (row['lang1'] == query_language or 
                row['lang2'] == query_language or 
                row['lang3'] == query_language):
                employees.loc[i, 'suitability_score'] += 20
                
            # Additional points if employee speaks customer's preferred languages
            if customer_languages:
                for lang in customer_languages:
                    if lang and (row['lang1'] == lang or 
                        row['lang2'] == lang or 
                        row['lang3'] == lang):
                        employees.loc[i, 'suitability_score'] += 10
                        break
        
        # Workload penalty (busier employees get lower scores)
        max_workload = employees['current_workload'].max()
        if max_workload > 0:
            employees['workload_score'] = (1 - (employees['current_workload'] / max_workload)) * 20
            employees['suitability_score'] += employees['workload_score']
        
        # Performance bonus (higher rated employees get higher scores)
        employees.loc[employees['avg_rating'] >= 4.5, 'suitability_score'] += 15
        employees.loc[(employees['avg_rating'] >= 4.0) & (employees['avg_rating'] < 4.5), 'suitability_score'] += 10
        
        # Sentiment-based adjustment
        if sentiment == 'negative':
            # For negative sentiment queries, strongly prefer higher-tier employees
            employees.loc[employees['employee_tier'] >= 4, 'suitability_score'] += 25
            employees.loc[employees['employee_tier'] == 3, 'suitability_score'] += 15
        
        return employees.sort_values(by='suitability_score', ascending=False)

    async def assign_query(self, query_data):
        """Main method to assign an employee to a query"""
        # Extract query_id and customer_id
        query_id = query_data.get('query_id')
        cust_id = query_data.get('cust_id')
        
        if not query_id or not cust_id:
            raise HTTPException(status_code=400, detail="Missing query_id or cust_id")
        
        # Get customer priority score
        priority_score = await self.get_customer_priority(cust_id)
        
        # Get customer languages preference
        customer_languages = await self.get_customer_languages(cust_id)
        
        # Get query's sub-branch
        sub_branch = self._get_query_sub_branch(query_data)
        
        # Load all employees
        all_employees = await self.load_employees()
        
        # Check for historical match
        historical_match_id = await self.find_historical_match(
            cust_id, query_data.get('department_name'), sub_branch
        )
        
        # Filter by department - must be in same department
        dept_employees = all_employees[
            all_employees['department_name'] == query_data.get('department_name')
        ]
        
        if dept_employees.empty:
            # Fallback if no department match
            dept_employees = all_employees
        
        # Calculate suitability scores
        ranked_employees = await self.calculate_employee_suitability(
            query_data, dept_employees, customer_languages
        )
        
        # Determine if we should prioritize historical match
        if historical_match_id and historical_match_id in ranked_employees['employee_id'].values:
            hist_match_score = ranked_employees.loc[
                ranked_employees['employee_id'] == historical_match_id, 
                'suitability_score'
            ].iloc[0]
            
            top_score = ranked_employees['suitability_score'].iloc[0]
            
            # Use historical match if within 15% of top match score
            if hist_match_score >= top_score * 0.85:
                assigned_employee_id = historical_match_id
            else:
                assigned_employee_id = ranked_employees['employee_id'].iloc[0]
        else:
            # No valid historical match, use top ranked
            assigned_employee_id = ranked_employees['employee_id'].iloc[0]
        
        # For high priority customers, double-check employee level
        if priority_score >= 75:
            assigned_emp_data = all_employees[
                all_employees['employee_id'] == assigned_employee_id
            ]
            
            if not assigned_emp_data.empty:
                assigned_emp_tier = assigned_emp_data['employee_tier'].iloc[0]
                
                # For very high priority, ensure at least tier 3
                if priority_score >= 90 and assigned_emp_tier < 3:
                    # Try to find a higher tier employee
                    high_tier_emps = ranked_employees[ranked_employees['employee_tier'] >= 3]
                    if not high_tier_emps.empty:
                        assigned_employee_id = high_tier_emps['employee_id'].iloc[0]
        
        # Calculate wait time based on priority and complexity
        wait_time_text, wait_time_interval = self.get_wait_time(
            priority_score, query_data.get('query_level', 1)
        )
        
        # Calculate appointment time
        now = datetime.now()
        wait_time_hours = 1  # Default 1 hour
        
        if "MINUTE" in wait_time_interval:
            wait_time_hours = int(wait_time_interval.split()[0]) / 60
        elif "HOUR" in wait_time_interval:
            wait_time_hours = int(wait_time_interval.split()[0])
            
        appointment_time = now + timedelta(hours=wait_time_hours)
        
        # Create appointment in Supabase
        appointment_data = {
            "cust_id": cust_id,
            "employee_id": assigned_employee_id,
            "query_id": query_id,
            "time_slot": appointment_time.isoformat(),
            "status": "scheduled"
        }
        
        try:
            # Insert appointment
            appointment_response = await self.supabase.table("appointment").insert(appointment_data).execute()
            
            # Update query status
            query_update = {
                "status": "assigned",
                "employee": assigned_employee_id
            }
            
            await self.supabase.table("query").update(query_update).eq("query_id", query_id).execute()
            
            # Check for ML enhancement suggestion
            ml_suggestion = await self.ml_content_similarity(query_id)
            
            if ml_suggestion and ml_suggestion != assigned_employee_id:
                # Log the ML suggestion for future improvement
                print(f"ML suggested employee {ml_suggestion} as alternative to {assigned_employee_id}")
                
            return {
                "query_id": query_id,
                "assigned_employee_id": assigned_employee_id,
                "expected_response_time": wait_time_text,
                "priority_score": priority_score,
                "historical_match_used": assigned_employee_id == historical_match_id,
                "department": query_data.get('department_name'),
                "sub_branch": sub_branch,
                "category": query_data.get('categories')
            }
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error creating appointment: {str(e)}")

# Function that can be imported and used in the main application router
async def assign_query_route(query: QueryInput, supabase: Client = Depends(get_supabase_client)):
    """Assign a banking query to the most appropriate employee"""
    assignment_system = BankingQueryAssignmentSystem(supabase)
    assignment_result = await assignment_system.assign_query(query.dict())
    return assignment_result

# Function to get customer priority without assignment
async def get_customer_priority_route(cust_id: str, supabase: Client = Depends(get_supabase_client)):
    """Get the priority score for a customer"""
    assignment_system = BankingQueryAssignmentSystem(supabase)
    priority = await assignment_system.get_customer_priority(cust_id)
    return {"cust_id": cust_id, "priority_score": priority}

# This allows the code to be imported as a module
# Example usage in main.py:
# from vyom_backend.src.decision_model import assign_query_route, get_customer_priority_route
# app.post("/assign-query", response_model=AssignmentResponse)(assign_query_route)
# app.get("/customer-priority/{cust_id}")(get_customer_priority_route)