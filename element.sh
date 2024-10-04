#! /bin/bash
# For second commit
# For third commit
# For fourth commit
# For the fifth commit

# The script should only take one argument.

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if (( $# == 0 )); then
  echo "Please provide an element as an argument."
elif (( $# >= 2 )); then
  echo "Please provide only one argument. The argument should be an element: an atomic number, element symbol, or element name."
else

  query_database() {
    local shell_arg=$1
    local query_type=$2
    local command_string="SELECT atomic_number, symbol, name FROM elements "

    case "$query_type" in
      atomic_number)
        command_string+="WHERE atomic_number = $shell_arg;"
        ;;
      element_symbol)
        command_string+="WHERE symbol = '$shell_arg';"
        ;;
      element_name)
        command_string+="WHERE name = '$shell_arg';"
        ;;
    esac

    local result_elements=$( $PSQL "$command_string" )

    if [[ -z $result_elements ]]; then
      echo "I could not find that element in the database."
    else
      local atomicNumber=${result_elements%%|*}

      local result_properties=$( $PSQL "SELECT * FROM properties WHERE atomic_number = $atomicNumber;" )

      # Extract the relevant data from result_elements and result_properties to output a sentence of the following form:

      # The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius.

      local -a result_elements_array

      IFS="|" read -r -a result_elements_array <<<"$result_elements"

      local -a result_properties_array

      IFS="|" read -r -a result_properties_array <<<"$result_properties"

      # Obtain the element's type by using a JOIN

      result_properties_w_element_type=$( $PSQL "SELECT p.*, t.type
          FROM properties p
          INNER JOIN types t ON p.type_id = t.type_id
          WHERE atomic_number = $atomicNumber")

      local -a result_properties_w_element_type_array

      IFS="|" read -r -a result_properties_w_element_type_array <<<"$result_properties_w_element_type"

      echo "The element with atomic number ${result_elements_array[0]} is ${result_elements_array[2]} (${result_elements_array[1]}). It's a ${result_properties_w_element_type_array[5]}, with a mass of ${result_properties_w_element_type_array[1]} amu. ${result_elements_array[2]} has a melting point of ${result_properties_w_element_type_array[2]} celsius and a boiling point of ${result_properties_w_element_type_array[3]} celsius."
    fi
  }

  if [[ $1 =~ ^[0-9]+$ ]]; then
    query_database $1 "atomic_number"

  elif [[ $1 =~ ^[a-zA-Z]+$ ]]; then
    if [[ ${#1} -le 2 ]]; then
      query_database $1 "element_symbol"
    else
      query_database $1 "element_name"
    fi
  else
    echo "I could not find that element in the database."
  fi
fi