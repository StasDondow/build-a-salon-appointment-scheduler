#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


SHOW_SERVICES() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}


MAIN_MENU() {

  while [[ -z $SERVICE_EXISTS ]]
  do
    SHOW_SERVICES
    echo -e "\nWhich service would you like to pick?"
    read SERVICE_ID_SELECTED
    SERVICE_EXISTS=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED;") 
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  PHONE_EXISTS=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE';") 
  if [[ -z $PHONE_EXISTS ]]
  then 
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';") 
  fi
  
  echo -e "\nWhat time are you booking the service for?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;") 
  echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

MAIN_MENU
