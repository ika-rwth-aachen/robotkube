#!/bin/bash

SEARCH_PREFIX="ROBOT_KUBE_TIMESTAMP"
SEARCH_STRING="$SEARCH_PREFIX\[[0-9]+\]=[0-9]+"
OUTPUT_LOGS_FILE="timestamps.log"
OUTPUT_CSV_FILE="timestamps.csv"
OUTPUT_ALL_CSV_FILE="timestamps-all.csv"

echo "Extracting timestamps from container logs ..."

# loop over all pods in the default namespace
for POD_NAME in $(kubectl get pods -o jsonpath='{.items[*].metadata.name}'); do
    echo $POD_NAME
    # loop over all containers in the pod
    for CONTAINER_NAME in $(kubectl get pod $POD_NAME -o jsonpath='{.spec.containers[*].name}'); do
        echo "- $CONTAINER_NAME"
        # extract the logs and search for the string
        kubectl logs $POD_NAME $CONTAINER_NAME | grep -oE "$SEARCH_STRING" >> $OUTPUT_LOGS_FILE
    done
done

# sort by timestamp index
sort -o $OUTPUT_LOGS_FILE $OUTPUT_LOGS_FILE
echo "=================="
echo "Found $(cat $OUTPUT_LOGS_FILE | wc -l) timestamps"
cat $OUTPUT_LOGS_FILE

# EXPECTED OUTPUT
#   ROBOT_KUBE_TIMESTAMP[0]=1683711106733
#   ROBOT_KUBE_TIMESTAMP[1]=1683711106733
#   ROBOT_KUBE_TIMESTAMP[2]=1683711106733

# convert to csv
sed "s/$SEARCH_PREFIX\[//g" $OUTPUT_LOGS_FILE | sed "s/\]=/,/g" > $OUTPUT_CSV_FILE

# EXPECTED OUTPUT
#   0,1683711106733
#   1,1683711106733
#   2,1683711106733

# convert to single csv-line appended to other csv file
python << EOF
import csv

timestamp_by_idx = {}
with open("$OUTPUT_CSV_FILE", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        if not len(row[0]) > 2:
            timestamp_by_idx[int(row[0])] = row[1]
timestamps = [timestamp_by_idx[i] if i in timestamp_by_idx else "" for i in range(max(timestamp_by_idx.keys())+1)]
with open("$OUTPUT_ALL_CSV_FILE", "a") as f:
    f.write(",".join(timestamps))
    f.write("\n")
EOF

# EXPECTED OUTPUT
#   1683711106733,1683711106733,1683711106733

rm $OUTPUT_LOGS_FILE
rm $OUTPUT_CSV_FILE
