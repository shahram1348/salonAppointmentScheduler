#!/bin/bash

PSQL="psql -X --username=shahram --dbname=salon --tuples-only --no-align -c"

echo -e "\n ~~~~~~~~ SHAHRAM BEAUTY SALON ~~~~~~~~ \n"

echo -e "\n Welcome to SHAHRAM BEAUTY SALON, how can I help you?\n" 


GET_APPOINTMENT() {
	SERVICES_LIST=$($PSQL "select service_id, name from services")
	IFS='|'
	echo "$SERVICES_LIST" | while read SERVICE_ID SERVICE_NAME
	do 
	   echo -e "$SERVICE_ID) $SERVICE_NAME"
	done
	unset IFS
	read SERVICE_ID_SELECTED 
	
  	while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  	do
  	  SERVICE_MENU
	done
 	SERVICE_SELECETION_RESULT=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")	  	
	
  	while [[ -z $SERVICE_SELECETION_RESULT ]]
  	do
  	  SERVICE_MENU
  	done
	SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

	echo "What's your phone number?"
	read CUSTOMER_PHONE
	CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_NAME ]]
	then
	 # ask for name of customer
	 echo "I don't have a record for that phone number, what's your name?"
	 read CUSTOMER_NAME
	 #update customers table by adding the name and phone number
	 CUSTOMERS_TABLE_UPDATE=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
	fi
	echo "What time would you like your $SERVICE_NAME, dear $CUSTOMER_NAME?"
	read SERVICE_TIME
	CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
	UPDATE_APPOINTMENTS_TABLE=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
	echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, dear $CUSTOMER_NAME."
} 

SERVICE_MENU() {
  	  echo "I could not find that service. What would you like today?"
	  IFS='|'
	  echo "$SERVICES_LIST" | while read SERVICE_ID SERVICE_NAME
	  do 
	    echo -e "$SERVICE_ID) $SERVICE_NAME"
	  done
	  unset IFS
	  read SERVICE_ID_SELECTED 
 	SERVICE_SELECETION_RESULT=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")	  	

}

GET_APPOINTMENT


