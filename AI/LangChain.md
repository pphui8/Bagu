# LangChain

[video](https://www.youtube.com/watch?v=yF9kGESAi3M&t=4709s)

## Basic Usage

```python
from langchain import OpenAI
llm = OpenAI(model="gpt-3.5-turbo", temperature=0.7)
response = llm.invoke("What is the capital of France?")
print(response)
```

### Using a Prompt Template

```python
from langchain import OpenAI, PromptTemplate
llm = OpenAI(model="gpt-3.5-turbo", temperature=0
response = llm.invoke(
    PromptTemplate(
        input_variables=["country"],
        template="What is the capital of {country}?",
    ).format(country="France")
)
print(response)
```

### Real time Chat

```python
# user conversation

from langchain_core.messages import AIMessage, SystemMessage, HumanMessage

chat_history = []

System_message = SystemMessage("Translate the following from English into Chinese")
chat_history.append(System_message)

while True:
  query = input("You: ")
  if query.lower() == "quit":
    break
  messages = chat_history + [HumanMessage(content=query)]
  response = model.invoke(messages).content
  chat_history.append(HumanMessage(content=query))
  chat_history.append(AIMessage(content=response))
  print(f"AI: {response}")
```

## Chain

![Chain](./Images/LangChain_chain.png)

```python
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate
from langchain.schema.output_parser import StrOutputParser
from langchain_google_genai import ChatGoogleGenerativeAI

load_dotenv()
model = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

prompt_template = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("user", "What is the capital of {country}?"),
    ]
)

chain = prompt_template | model | StrOutputParser()
response = chain.invoke({"country": "France"})
print(response)
```

### Under the Hood

```python
model = ChatGoogleGenerativeAI(model="gemini-2.0-flash")
prompt_template = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("user", "What is the capital of {country}?"),
    ]
)

format_prompt = RunnableLambda(lambda x: prompt_template.format(**x))
invoke_model = RunnableLambda(lambda x: model.invoke(x.to_messages()))
parse_output = RunnableLambda(lambda x: x.content)

chain = RunnableSequence(first=format_prompt, middle=invoke_model, last=parse_output)
response = chain.invoke({"country": "France"})
print(response)
```

### Extended Chain

```python
model = OpenAI(model="gpt-3.5-turbo", temperature=0.7)
prompt_template = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "What is the capital of {country}?"),
    ]
)

uppercase_output = RunnableLambda(lambda x: x.upper())
count_characters = RunnableLambda(lambda x: len(x))

chain = prompt_template | model | StringOutputParser() | uppercase_output | count_characters
response = chain.invoke({"country": "France"})
print(response)  # Output: 6
```

## Parallel Chains

Example: Analyzing pros and cons simultaneously.

![Parallel Chains](./Images/LangChain_parallel.png)

```python
model = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

prompt_template = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("user", "List the features of {product}."),
    ]
)

def analyze_pros(features):
    pros_template = ChatPromptTemplate.from_messages(
        [
            ("system", "You are a helpful assistant."),
            ("user", "Given these features: {features}, what are the pros of this product?"),
        ]
    )
    return model.invoke(pros_template.format(features = features))

def analyze_cons(features):
    cons_template = ChatPromptTemplate.from_messages(
        [
            ("system", "You are a helpful assistant."),
            ("user", "Given these features: {features}, what are the cons of this product?"),
        ]
    )
    return model.invoke(cons_template.format(features = features))

pros_branch = (
    RunnableLambda(lambda x: analyze_pros(x) | model | StrOutputParser())
)

cons_branch = (
    RunnableLambda(lambda x: analyze_cons(x) | model | StrOutputParser())
)

chain = (
    prompt_template
    | model
    | StrOutputParser()
    | RunnableParallel(Branches={"pros": pros_branch, "cons": cons_branch})
    | RunnableLambda(lambda x: f"Pros: {x["branches"]["pros"]}, Cons: {x["branches"]["cons"]}")
)
response = chain.invoke({"product": "iPhone"})
print(response)
```

or
```python
from langchain.prompts import PromptTemplate
from langchain.schema.output_parser import StrOutputParser
from langchain.chat_models import ChatOpenAI
from langchain.schema.runnable import RunnableParallel, RunnableLambda
from langchain_core.runnables import RunnableLambda, RunnableParallel, RunnablePassthrough

model = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

feature_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful product expert."),
        ("user", "List the key technical features of the {product}."),
    ]
)

pros_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful product analyst."),
        ("user", "Given these features:\n\n{features}\n\nWhat are the main pros or advantages of the {product}?"),
    ]
)

cons_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful product analyst."),
        ("user", "Given these features:\n\n{features}\n\nWhat are the main cons or disadvantages of the {product}?"),
    ]
)


feature_generation_chain = feature_prompt | model | StrOutputParser()

pros_chain = pros_prompt | model | StrOutputParser()
cons_chain = cons_prompt | model | StrOutputParser()


# THE MAIN CHAIN
chain = (
    RunnablePassthrough.assign(
        features=feature_generation_chain
    )
    | RunnableParallel(
        pros=pros_chain,
        cons=cons_chain
    )
)

response = chain.invoke({"product": "Apple Vision Pro"})

print("------ Pros ------")
print(response['pros'])
print("\n------ Cons ------")
print(response['cons'])
```

## Branching

First categorize the input, then process according to the category.
![Branching](./Images/LangChain_branching.png)

```python
model = OpenAI(model="gpt-3.5-turbo", temperature=0.7)

classification_prompt = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "Classify the feedback into positive, negative, or neutral: {feedback}"),
    ]
)

positive_feedback_template = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "Generate a thank you email for a positive feedback: {feedback}"),
    ]
)

negative_feedback_template = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "Generate a response for a negative feedback: {feedback}"),
    ]
)

natural_language_template = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "Generate a natural language response for the feedback: {feedback}"),
    ]
)

escalate_template = PromptTemplate(
    [
        ("system", "You are a helpful assistant."),
        ("user", "Generate an escalation response for the feedback: {feedback}"),
    ]
)

branches = RunnableBranch(
    (
        lambda x: 'positive' in x,
        positive_feedback_template | model | StringOutputParser()
    ),
    (
        lambda x: 'negative' in x,
        negative_feedback_template | model | StringOutputParser()
    ),
    (
        lambda x: 'neutral' in x,
        natural_language_template | model | StringOutputParser()
    ),
    else=escalate_template | model | StringOutputParser()
)

classification_chain = (
    classification_prompt
    | model
    | StringOutputParser()
    | branches
)

response = classification_chain.invoke({"feedback": "I love the new features!"})
print(response)  # Output: Thank you for your positive feedback!
```

## RAG

![RAG](./Images/LangChain_rag.png)
![RAG2](./Images/LangChain_rag2.png)

#### Why we need splittin into chunks
When dealing with large documents, we need to split them into smaller chunks to ensure that the model can process them effectively. This is crucial for tasks like question answering, where the model needs to retrieve relevant information from a large corpus.

```python
loader = TextLoader("test.txt")
documents = loader.load()

text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
print("Number of document chunks: ", len(docs))
embeddings = GoogleGenerativeAIEmbeddings(
    model="models/gemini-embedding-exp-03-07"
)
doc_embeddings = embeddings.embed_documents([doc.page_content for doc in docs])
persist_directory = "db"
db = Chroma.from_documents(docs, embeddings, persist_directory=persist_directory)
```

```python
from langchain.prompts import ChatPromptTemplate
from langchain.schema.output_parser import StrOutputParser

model = ChatGoogleGenerativeAI(model="gemini-2.0-flash")
db = Chroma(persist_directory="db", embedding_function=embeddings)

retriever = db.as_retriever(search_type="similarity_score_threshold", search_kwargs={"k": 3, "score_threshold": 0.4})
prompt = "When did Obama become president?"
response = retriever.invoke(prompt)

for i, doc in enumerate(response, 1):
  print(f"Document {i}: {doc.page_content}")
  if doc.metadata:
    print(f"Source: {doc.metadata.get('source', 'Unknown')}\n")
```

## Metadata
Metadata is additional information about the documents, such as the source, author, or date. It helps in filtering and retrieving relevant documents based on specific criteria.

Metadata is additional structured data that discribes our target data. (Context, timestamps, categories)


### Text splitting

| splitter | description | example |
|----------|-------------|-----------|
| Character-based | Splits text into chunks based on character count. Useful for small documents. | `CharacterTextSplitter(chunk_size=1000, chunk_overlap=100)` |
| Sentence-based | Splits text into chunks based on sentence boundaries. Useful for maintaining context in natural language. | `SentenceTextSplitter(chunk_size=1000)` |
| Token-based | Splits text into chunks based on token count. Useful for large documents where token limits are a concern. | `TokenTextSplitter(chunk_size=512, chunk_overlap=100)` |
| Recursive Character-based (most used) | Splits text recursively into smaller chunks until a specified size is reached. Useful for hierarchical documents. | `RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)` |

When to use which splitter:
1. **Character-based**: Use for small documents where you need precise control over chunk size.
2. **Sentence-based**: Use when maintaining natural language context is important, such as in conversational data.
3. **Token-based**: Use for large documents where token limits are a concern, especially with models that have strict token limits.
4. **Recursive Character-based**: Use for hierarchical documents or when you want to ensure that chunks are not too large while still maintaining some overlap.

### Retriver
Retrievers are used to fetch relevant documents from a database based on a query. They can be configured to use different search methods, such as similarity search or keyword search.

#### Similarity Search
This method retrieves documents based on their similarity to the query. It uses embeddings to measure the semantic similarity between the query and the documents.

```python
retriever = db.as_retriever(
    search_type="similarity"
    search_kwargs={"k": 3}
```
or with a score threshold
```python
retriever = db.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 3, "score_threshold": 0.4}
)
```

### Max Marginal Relevance (MMR)
This method **balance between relevance and diversity** in the retrieved documents. It ensures that the retrieved documents are not only relevant to the query but also diverse enough to provide a comprehensive answer.

`fetch_k` specifies the number of documents to retrieve based on similarity

`lambda_mult` controls the trade-off between relevance and diversity. A higher value means more emphasis on diversity.

```python
retriever = db.as_retriever(
    search_type="mmr",
    search_kwargs={
        "k": 3,
        "fetch_k": 10,
        "lambda_mult": 0.5
    }
)
```

### One off question answering
```python
