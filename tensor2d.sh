#!/bin/bash

SCALE=1000  # 3 Nachkommastellen

float_to_int() {
    local float_str="$1"
    local int_part="${float_str%.*}"
    local frac_part="${float_str#*.}"
    if [[ "$float_str" == "$int_part" ]]; then
        frac_part="0"
    fi
    while [[ ${#frac_part} -lt 3 ]]; do
        frac_part="${frac_part}0"
    done
    frac_part="${frac_part:0:3}"
    echo "$(( int_part * SCALE + frac_part ))"
}

print_value() {
    local value="$1"
    local negative=""
    if (( value < 0 )); then
        value=$(( -value ))
        negative="-"
    fi
    local int_part=$(( value / SCALE ))
    local frac_part=$(( value % SCALE ))
    printf "%s%d.%03d " "$negative" "$int_part" "$frac_part"
}

create_tensor2d() {
    local -n tensor=$1
    local -n rows=$2
    local -n cols=$3
    rows="$4"
    cols="$5"
    shift 5
    tensor=()
    for value in "$@"; do
        int_value=$(float_to_int "$value")
        tensor+=("$int_value")
    done
}

print_tensor2d() {
    local -n tensor=$1
    local rows="$2"
    local cols="$3"
    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            index=$(( i * cols + j ))
            print_value "${tensor[index]}"
        done
        echo
    done
}

add_tensors2d() {
    local -n result=$1
    local -n tensor_a=$2
    local -n tensor_b=$3
    local size="${#tensor_a[@]}"
    result=()
    for ((i=0; i<size; i++)); do
        result+=($(( tensor_a[i] + tensor_b[i] )))
    done
}

multiply_tensors2d() {
    local -n result=$1
    local -n tensor_a=$2
    local -n tensor_b=$3
    local size="${#tensor_a[@]}"
    result=()
    for ((i=0; i<size; i++)); do
        result+=($(( tensor_a[i] * tensor_b[i] / SCALE )))
    done
}

run_tests() {
    echo "== Starte 2D-Tests =="

    create_tensor2d tensor1 rows1 cols1 2 3 1.1 2.2 3.3 4.4 5.5 6.6
    create_tensor2d tensor2 rows2 cols2 2 3 0.9 0.8 0.7 0.6 0.5 0.4

    echo "Tensor 1:"
    print_tensor2d tensor1 "$rows1" "$cols1"
    echo "Erwartet:"
    echo "1.100 2.200 3.300"
    echo "4.400 5.500 6.600"

    echo
    echo "Tensor 2:"
    print_tensor2d tensor2 "$rows2" "$cols2"
    echo "Erwartet:"
    echo "0.900 0.800 0.700"
    echo "0.600 0.500 0.400"

    add_tensors2d tensor_sum tensor1 tensor2
    echo
    echo "Summe:"
    print_tensor2d tensor_sum "$rows1" "$cols1"
    echo "Erwartet:"
    echo "2.000 3.000 4.000"
    echo "5.000 6.000 7.000"

    multiply_tensors2d tensor_product tensor1 tensor2
    echo
    echo "Produkt:"
    print_tensor2d tensor_product "$rows1" "$cols1"
    echo "Erwartet:"
    echo "0.990 1.760 2.310"
    echo "2.640 2.750 2.640"

    echo
    echo "== Tests abgeschlossen =="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
