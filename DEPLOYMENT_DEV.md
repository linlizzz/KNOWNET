### Start the database servers dynamodb and neo4j in docker
```
docker compose up -d
```
### Start the app
```
pnpm dev
```
### Test dynamodb
### List all tables to verify Chats exists
```
aws dynamodb list-tables --endpoint-url http://localhost:8000
```

### Test neo4j
```
MATCH ()-[r]->()
RETURN COUNT(r) AS relationshipCount
```
### Run the post_proccessing script to check the data in the 'Chats' table
```
python post_proccessing/chat_table_data.py
```
