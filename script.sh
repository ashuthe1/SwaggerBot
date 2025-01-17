source .env

DOWNLOAD_DIR="$HOME/Downloads"

function exit_with_error() {
  echo "Error: $1"
  exit 1
}

echo "Fetching the last message..."
MESSAGE_RESPONSE=$(curl -s --location \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  "https://webexapis.com/v1/messages?roomId=$ROOM_ID&max=1")


if [ -z "$MESSAGE_RESPONSE" ]; then
  exit_with_error "API call failed: Empty response."
fi


MESSAGE_ID=$(echo "$MESSAGE_RESPONSE" | jq -r '.items[0].id')
PARENT_ID=$MESSAGE_ID
FILE_LINK=$(echo "$MESSAGE_RESPONSE" | jq -r '.items[0].files[0]')

if [ -z "$MESSAGE_ID" ] || [ "$MESSAGE_ID" == "null" ]; then
  exit_with_error "Failed to retrieve Message ID."
fi

if [ -z "$FILE_LINK" ] || [ "$FILE_LINK" == "null" ]; then
  exit_with_error "No file link found in the last message."
fi

JSON_FILE_NAME="$MESSAGE_ID.json"
CLI_COMMAND="cp $DOWNLOAD_DIR/$JSON_FILE_NAME $DOWNLOAD_DIR/output.txt"

curl -s --location \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  "$FILE_LINK" -o "$DOWNLOAD_DIR/$JSON_FILE_NAME"

if [ ! -f "$DOWNLOAD_DIR/$JSON_FILE_NAME" ]; then
  exit_with_error "Failed to download the file."
fi

$CLI_COMMAND > "$DOWNLOAD_DIR/output.txt"

if [ ! -f "$DOWNLOAD_DIR/output.txt" ]; then
  exit_with_error "CLI command failed to generate output."
fi

echo "CLI command executed. Output saved to $DOWNLOAD_DIR/output.txt"

SEND_RESPONSE=$(curl -s --location \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --form "files=@\"$DOWNLOAD_DIR/output.txt\"" \
  --form "roomId=\"$ROOM_ID\"" \
  --form "parentId=\"$PARENT_ID\"" \
  "https://webexapis.com/v1/messages")


if [ -z "$SEND_RESPONSE" ] | jq -e '.message'; then
  ERROR_MSG=$(echo "$SEND_RESPONSE" | jq -r '.message')
  exit_with_error "Failed to send message: $ERROR_MSG"
fi

echo "Message sent successfully."
exit 0