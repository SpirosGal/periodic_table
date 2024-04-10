#!/bin/bash

# Function to perform the database query
query_db() {
    local query=$1
    psql --username=freecodecamp --dbname=periodic_table -t -A -F $'\t' -c "$query"
}

# Function to get type from types table
get_type() {
    local type_id=$1
    local type_result=$(query_db "SELECT type FROM types WHERE type_id = $type_id;")
    echo "$type_result"
}

# Check if no argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
else
    # Determine if the argument is a number (atomic number) or a string (symbol or name)
    if [[ $1 =~ ^[0-9]+$ ]]; then
        # Argument is a number, search by atomic number
        result=$(query_db "SELECT e.atomic_number, e.symbol, e.name, p.type_id, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number WHERE e.atomic_number = $1;")
    else
        # Argument is not a number, search by symbol or name
        result=$(query_db "SELECT e.atomic_number, e.symbol, e.name, p.type_id, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number WHERE e.symbol ILIKE '$1' OR e.name ILIKE '$1';")
    fi

    # Check if the query returned a result
    if [[ -z $result ]]; then
        echo "I could not find that element in the database."
    else
        # Read the query result into variables
        IFS=$'\t' read -r atomic_number symbol name type_id atomic_mass melting_point boiling_point <<< "$result"
        
        # Get the type from the types table based on type_id
        type=$(get_type "$type_id")
        
        # Display the element information
        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    fi
    
fi
