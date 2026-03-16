# Optional metadata used in reports when working with HF + DVC.
HF_DATASET_URL ?= https://huggingface.co/datasets/milotix/drug200/blob/main/drug200.csv
DATA_FILE ?= data/drug200.csv

# Install Python dependencies used by training, evaluation, and deployment.
install:
	# TODO: upgrade pip and install dependencies from requirements.txt
	echo "TODO: implement install target"
	python -m pip install --upgrade pip
	pip install -r requirements.txt

# Auto-format Python files in the repository root.
format:
	black *.py

# Train the model and write artifacts under ./model and ./results.
train:
	# TODO: reproduce the DVC pipeline
	echo "TODO: implement train target"
	python train.py

# Minimal DVC + HF flow for class exercises.
# This repo uses `dvc import` from Hugging Face (no writable DVC remote required).
setup_dvc_hf:
	echo "Using DVC import workflow from Hugging Face (no remote token setup needed)."

# Pull imported dataset metadata/content and run training.
train_dvc: setup_dvc_hf
	# TODO: pull the dataset tracked by DVC
	# TODO: run the training pipeline through DVC
	echo "TODO: implement train_dvc target"
	dvc pull data
	python train.py

# Simple CML report for students: metrics, figure, and DVC status.
eval_cml_and_dvc:
    echo "## Model Metrics" > report.md
    cat ./results/metrics.txt >> report.md
    echo "\n## Confusion Matrix Plot" >> report.md
    echo '![Confusion Matrix](./results/model_results.png)' >> report.md
    echo "\n## Data Version (DVC)" >> report.md
    dvc status -c >> report.md 2>&1 || echo "DVC status unavailable" >> report.md
    cml comment create report.md

# Authenticate Hugging Face CLI with token passed as HF=<token>.
hf-login:
	# Install the latest version with CLI support
	pip install -U "huggingface_hub[cli]"
	# Use the new 'hf' binary for authentication
	hf auth login --token $(HF) --add-to-git-credential

# Upload app/model/metrics into the Hugging Face Space repository.
push-hub:
	# Use the new 'hf upload' syntax
	hf upload milotix/DrugClassification ./app . --repo-type=space --commit-message="Sync App files"
	hf upload milotix/DrugClassification ./model /model --repo-type=space --commit-message="Sync Model"
	hf upload milotix/DrugClassification ./results /metrics --repo-type=space --commit-message="Sync Metrics"

# Full deploy flow: login then push files to the Space.
deploy: hf-login push-hub
