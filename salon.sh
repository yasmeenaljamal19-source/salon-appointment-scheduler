#!/bin/bash
echo "Welcome to My Salon!"
echo "Here are our services:"
psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -F ") " -c "SELECT service_id, name FROM services ORDER BY service_id;"
echo "Which service would you like?"
read SERVICE_ID_SELECTED
while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
do
  echo "Please enter a valid service number:"
  psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -F ") " -c "SELECT service_id, name FROM services ORDER BY service_id;"
  read SERVICE_ID_SELECTED
done
SERVICE_NAME=$(psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
while [[ -z $SERVICE_NAME ]]
do
  echo "This service is not available."
  echo "Please select a service:"

  psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -F ") " -c "SELECT service_id, name FROM services ORDER BY service_id;"

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME=$(psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  fi
done

echo "You selected: $SERVICE_NAME"

echo "What's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$(psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -v phone="$CUSTOMER_PHONE" <<'SQL'
SELECT name FROM customers WHERE phone = :'phone';
SQL
)

if [[ -z $CUSTOMER_NAME ]]
then
  echo "I don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  psql -h 127.0.0.1 -U freecodecamp -d salon -v phone="$CUSTOMER_PHONE" -v customer_name="$CUSTOMER_NAME" <<'SQL'
INSERT INTO customers (phone, name)
VALUES (:'phone', :'customer_name');
SQL
else
  echo "Welcome back, $CUSTOMER_NAME!"
fi
echo "What time would you like your appointment?"
read SERVICE_TIME
CUSTOMER_ID=$(psql -h 127.0.0.1 -U freecodecamp -d salon -t -A -v phone="$CUSTOMER_PHONE" <<'SQL'
SELECT customer_id FROM customers WHERE phone = :'phone';
SQL
)
psql -h 127.0.0.1 -U freecodecamp -d salon \
  -v customer_id="$CUSTOMER_ID" \
  -v service_id="$SERVICE_ID_SELECTED" \
  -v service_time="$SERVICE_TIME" <<'SQL'
INSERT INTO appointments (customer_id, service_id, time)
VALUES (:customer_id, :service_id, :'service_time');
SQL
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."