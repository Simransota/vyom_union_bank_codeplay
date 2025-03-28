def create_query_in_neo4j(result, query_complexity, date_time_str, estimated_time, priority_level, language, 
                        db_sentiment, category_str, sub_dept, department_name, cust_id):
    """
    Create a Query node in Neo4j along with its relationships.
    
    Args:
        result: Query ID
        query_complexity: Level of query complexity
        date_time_str: Formatted date time string
        estimated_time: Estimated time to resolve
        priority_level: Priority level of the query
        language: Language of the query
        db_sentiment: Sentiment analysis result
        category_str: Comma-separated string of categories
        sub_dept: Sub-department ID
        department_name: Department name
        cust_id: Customer ID
    
    Returns:
        List of cypher queries to execute
    """
    cypher_queries = []
    cypher_queries.append(f"CREATE (q:Query {{query_id: {result}, query_level: {query_complexity}, redirected: {False}, created: '{date_time_str}', updated: '{date_time_str}', estimated_time: {estimated_time}, priority_level: {priority_level}, language: '{language}',sentient:'{db_sentiment}',status:'Active'}});")

    # Create HAS_CATEGORY Relationships
    for category in category_str.split(','):
        category = category.strip()  # Remove any extra whitespace
        if category:  # Only process non-empty categories
            cypher_queries.append(f"MATCH (q:Query {{query_id: {result}}}) MERGE (cat:Category {{category_id: '{category}'}}) MERGE (q)-[:HAS_CATEGORY]->(cat);")

    # Create HAS_SUBDEPARTMENT Relationships
    cypher_queries.append(f"MATCH (q:Query {{query_id: {result}}}) MERGE (sub:SubDepartment {{subdept_id: '{sub_dept}'}}) MERGE (q)-[:HAS_SUBDEPARTMENT]->(sub);")

    # Create ASSOCIATED_WITH_DEPARTMENT Relationships
    cypher_queries.append(f"MATCH (q:Query {{query_id: {result}}}) MERGE (d:Department {{dept_id: '{department_name}'}}) MERGE (q)-[:ASSOCIATED_WITH_DEPARTMENT]->(d);")
    
    # Create RAISED_BY Relationships
    cypher_queries.append(f"MATCH (q:Query {{query_id: {result}}}), (c:Customer {{customer_id: {cust_id}}}) MERGE (q)-[:RAISED_BY]->(c);")
    
    return cypher_queries

def employee_query_neo4j(result, employee_id=None, branch_id=None):
    """
    Create ASSOCIATED_WITH_BRANCH and HANDLED_BY relationships in Neo4j.
    
    Args:
        result: Query ID
        employee_id: Optional Employee ID
        branch_id: Optional Branch ID
    
    Returns:
        List of Cypher query strings
    """
    queries = []
    
    if branch_id is not None:
        queries.append(f"MATCH (q:Query {{query_id: {result}}}), (b:Branch {{branch_id: {branch_id}}}) MERGE (q)-[:ASSOCIATED_WITH_BRANCH]->(b);")
    
    if employee_id is not None:
        queries.append(f"MATCH (q:Query {{query_id: {result}}}), (e:Employee {{employee_id: {employee_id}}}) MERGE (q)-[:HANDLED_BY]->(e);")
    
    return queries

