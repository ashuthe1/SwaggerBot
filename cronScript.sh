source .env

SCRIPT_PATH="$CURRENT_DIRECTORY/swaggerScript.sh"
ERROR_LOG="$CURRENT_DIRECTORY/error.log"

while true; do
    $SCRIPT_PATH
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error: Script execution failed with exit code $EXIT_CODE at $(date)" >> $ERROR_LOG
        echo "Retrying after $INTERVAL seconds..."
    fi

    sleep $INTERVAL
done
