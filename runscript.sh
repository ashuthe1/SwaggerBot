SCRIPT_PATH="/Users/ashugaut/Learnings/SwaggerBot/script.sh"
ERROR_LOG="/Users/ashugaut/Learnings/SwaggerBot/error.log"

while true; do
    $SCRIPT_PATH
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error: Script execution failed with exit code $EXIT_CODE at $(date)" >> $ERROR_LOG
        echo "Retrying after 1 hour..."
    fi

    sleep 3600 # Wait for 1 hour
done
