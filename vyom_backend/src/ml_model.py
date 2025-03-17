from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Similarity threshold (75%)
SIMILARITY_THRESHOLD = 0.50

def process_query(current_query, last_three_queries):
    if not current_query:
        return {'status': 'error'}
    if not last_three_queries:
        return {
            'status': 'not_enough_info',
        }
    # Prepare data for vectorization
    all_queries = last_three_queries + [current_query]
    
    # Vectorize the queries
    vectorizer = CountVectorizer(stop_words='english')
    try:
        vectors = vectorizer.fit_transform(all_queries).toarray()
    except ValueError:
        return {'status': 'error', 'message': 'Invalid query content'}
    
    # Get the current query vector (last one)
    current_vector = vectors[-1]
    
    # Compare with recent queries
    for i, recent_vector in enumerate(vectors[:-1]):
        similarity = cosine_similarity([recent_vector], [current_vector])[0][0]
        if similarity >= SIMILARITY_THRESHOLD:
            return {
                'status': 'ignored'
            }
    return {
        'status': 'success',
    }


