#!/bin/bash
# A salon appointment scheduling script for a freeCodeCamp Relational Database project

# Connect to database
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Print welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"

# Print list of services
LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")
echo -e "\n$LIST_OF_SERVICES" | sed 's/|/) /'

# Get desired service from user
read SERVICE_ID_SELECTED

# Check if input was valid
while (( $SERVICE_ID_SELECTED < 1 || $SERVICE_ID_SELECTED > 5 )); do
  # Print error, and ask user for valid input
  echo -e "\nI could not find that service. What would you like today?"
  echo -e "\n$LIST_OF_SERVICES" | sed 's/|/) /'

  # Get desired service from user
  read SERVICE_ID_SELECTED
done

# Set chosen service with valid input
SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

# Ask user for their number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Reference against customers table
CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If they don't exist, create new customer
if [[ -z $CUSTOMER_PHONE_RESULT ]]
then
  # Ask for their name
  echo -e "\nI don't have a record for that phone number, what is your name?"
  read CUSTOMER_NAME
  
  # Set customer's phone number and name
  CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
else
  # Get customer's name from db
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Ask user for a time for their appointment
echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer's id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Insert service time into appointments table
SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

# Print success message
echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."