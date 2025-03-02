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

matrix_multiply() {
    local -n result=$1
    local -n tensor_a=$2
    local rows_a=$3
    local cols_a=$4
    local -n tensor_b=$5
    local rows_b=$6
    local cols_b=$7

    if (( cols_a != rows_b )); then
        echo "Fehler: Ungültige Matrizen für Multiplikation." >&2
        return 1
    fi

    result=()
    for ((i=0; i<rows_a; i++)); do
        for ((j=0; j<cols_b; j++)); do
            sum=0
            for ((k=0; k<cols_a; k++)); do
                index_a=$(( i * cols_a + k ))
                index_b=$(( k * cols_b + j ))
                product=$(( tensor_a[index_a] * tensor_b[index_b] / SCALE ))
                sum=$(( sum + product ))
            done
            result+=("$sum")
        done
    done
}

relu_tensor2d() {
    local -n result=$1
    local -n tensor=$2
    result=()
    for value in "${tensor[@]}"; do
        if (( value < 0 )); then
            result+=(0)
        else
            result+=("$value")
        fi
    done
}

sigmoid_tensor2d() {
    local -n result=$1
    local -n tensor=$2
    result=()
    for value in "${tensor[@]}"; do
        if (( value > 6000 )); then
            result+=("$SCALE")
        elif (( value < -6000 )); then
            result+=(0)
        else
            local exp_value=$(( SCALE * SCALE / (SCALE + value) ))  # Näherung
            result+=("$exp_value")
        fi
    done
}

run_tests() {
    echo "== Starte NN-Tests =="

    create_tensor2d input rows_in cols_in 1 3 1.0 2.0 3.0
    create_tensor2d weights rows_w cols_w 3 2 0.5 0.2 0.8 0.4 0.3 0.9
    create_tensor2d bias rows_b cols_b 1 2 0.1 0.2

    echo "Input:"
    print_tensor2d input "$rows_in" "$cols_in"
    echo

    echo "Weights:"
    print_tensor2d weights "$rows_w" "$cols_w"
    echo

    echo "Bias:"
    print_tensor2d bias "$rows_b" "$cols_b"
    echo

    matrix_multiply layer_output input "$rows_in" "$cols_in" weights "$rows_w" "$cols_w"
    add_tensors2d layer_output_with_bias layer_output bias
    echo "Layer Output (vor Activation):"
    print_tensor2d layer_output_with_bias "$rows_in" "$cols_w"
    echo

    relu_tensor2d activated_output layer_output_with_bias
    echo "Layer Output (ReLU aktiviert):"
    print_tensor2d activated_output "$rows_in" "$cols_w"
    echo

    echo "== Tests abgeschlossen =="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
