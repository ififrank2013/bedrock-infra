#!/bin/bash
# Script to generate grading.json without sensitive data

set -e

echo "Generating grading.json from Terraform outputs..."

cd terraform

# Generate raw terraform output
terraform output -json > ../grading_raw.json

# Remove sensitive data using jq
cat ../grading_raw.json | jq 'walk(
  if type == "object" and 
     has("sensitive") and 
     .sensitive == true and 
     has("value") 
  then 
    .value = "[REDACTED - See GitHub Secrets]" 
  else 
    . 
  end
)' > ../grading.json

# Clean up temporary file
rm ../grading_raw.json

echo "grading.json generated successfully (sensitive data redacted)"
echo "Location: $(pwd)/../grading.json"
