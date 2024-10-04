#! /bin/bash

# The script should only take one argument.

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if (( $# == 0 )); then
  echo "Please provide an element as an argument."
elif (( $# >= 2 )); then
  echo "Please provide only one argument. The argument should be an element: an atomic number, element symbol, or element name."
else
  echo "OUTERMOST ELSE: The shell argument is: $1"

  query_database() {
    local shell_arg=$1
    local query_type=$2
    local command_string="SELECT atomic_number, symbol, name FROM elements "
    echo "Hello, from query_database function. Shell argument is: $shell_arg"

    case "$query_type" in
      atomic_number)
        echo "Hello, from case statement 1. Query type is $query_type"
        command_string+="WHERE atomic_number = $shell_arg;"
        ;;
      element_symbol)
        echo "Hello, from case statement 2. Query type is $query_type"
        command_string+="WHERE symbol = '$shell_arg';"
        ;;
      element_name)
        echo "Hello, from case statement 3. Query type is $query_type"
        command_string+="WHERE name = '$shell_arg';"
        ;;
    esac

    echo -e "\nAfter the CASE statement...\n\nNow querying database with this command string:\n\n $command_string"

    local result_elements=$( $PSQL "$command_string" )

    if [[ -z $result_elements ]]; then
      echo "The query produced zero records."
    else
      echo -e "\nresult_elements is: $result_elements"

      echo -e "\nNow obtaining data from the 'properties' table by querying the database using the output from the command string database query...\n"

      local atomicNumber=${result_elements%%|*}
      echo "The atomicNumber is ${atomicNumber}."

      local result_properties=$( $PSQL "SELECT * FROM properties WHERE atomic_number = $atomicNumber;" )

      echo -e "\nresult_properties is: $result_properties"

      # Extract the relevant data from result_elements and result_properties to output a sentence of the following form:

      # The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius.

      local -a result_elements_array

      IFS="|" read -r -a result_elements_array <<<"$result_elements"

      local -a result_properties_array

      IFS="|" read -r -a result_properties_array <<<"$result_properties"

      echo "The element with atomic number ${result_elements_array[0]} is ${result_elements_array[2]} (${result_elements_array[1]}). It's a ${result_properties_array[1]}, with a mass of ${result_properties_array[2]} amu. ${result_elements_array[2]} has a melting point of ${result_properties_array[3]} celsius and a boiling point of ${result_properties_array[4]} celsius."
    fi
  }

  if [[ $1 =~ ^[0-9]+$ ]]; then
    echo "The argument is entirely a numeric string."
    query_database $1 "atomic_number"

  elif [[ $1 =~ ^[a-zA-Z]+$ ]]; then
    echo "The argument is entirely a letter string."

    if [[ ${#1} -le 2 ]]; then
      echo "The argument is an element symbol."
      query_database $1 "element_symbol"
    else
      echo "The argument is an element name."
      query_database $1 "element_name"
    fi
  else
    echo "I could not find that element in the database."
  fi
fi