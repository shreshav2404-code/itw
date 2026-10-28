# ITW Notebooks

This repository contains Jupyter notebooks for experimenting with text embeddings, semantic search, vector databases, and retrieval-augmented generation (RAG) using Python.

## Contents

- `itw.ipynb` through `itw6.ipynb`: Earlier experiments and demonstrations.
- `itw7.ipynb` and `itw7_v2.ipynb`: RAG chatbot experiments using sentence embeddings and transformer models.
- `itw8.ipynb`: ChromaDB document storage and vector-search experiment.
- `itw9.ipynb`: Text splitting with `RecursiveCharacterTextSplitter`, using 50-character chunks and 10-character overlap.
- `itw10.ipynb`: End-to-end RAG example using ChromaDB, the `all-MiniLM-L6-v2` embedding model, and Google FLAN-T5-small to retrieve relevant documents and generate answers.

## Requirements

- Python 3.11 or later
- Jupyter Notebook or JupyterLab
- `chromadb`
- `sentence-transformers`
- `transformers`
- `torch`

Install the main dependencies in the active notebook environment:

```bash
python -m pip install chromadb sentence-transformers transformers torch
```

## Running `itw10.ipynb`

1. Open `itw10.ipynb` in VS Code or Jupyter.
2. Select the project's Python environment as the notebook kernel.
3. Run the cells from top to bottom.
4. The notebook creates or updates a local ChromaDB collection in `d:/itw/chromadb`.
5. Use the final interactive cell to ask questions; type `exit` to stop.

The notebook stores seven example documents, embeds them with `all-MiniLM-L6-v2`, retrieves the three most relevant documents for each question, and passes the retrieved context to FLAN-T5-small for answer generation.

## Notes

- The first model execution may download model files from Hugging Face.
- The interactive cell waits for user input and should be stopped manually when no longer needed.
- Local virtual environments and generated vector database directories are not required to run the notebooks from a fresh checkout.
