#!/bin/bash

SCALE=1000  # 3 Nachkommastellen

# === Hilfsfunktion: Float-String in Integer umwandeln ===
# z.B. "1.234" -> 1234
float_to_int() {
    local float_str="$1"
    local int_part="${float_str%.*}"
    local frac_part="${float_str#*.}"

    # Fehlende Teile auffüllen
    if [[ "$float_str" == "$int_part" ]]; then
        frac_part="0"
    fi
    while [[ ${#frac_part} -lt 3 ]]; do
        frac_part="${frac_part}0"
    done
    frac_part="${frac_part:0:3}"

    echo "$(( int_part * SCALE + frac_part ))"
}

# === Tensor erstellen ===
create_tensor() {
    local -n tensor=$1
    shift
    tensor=()
    for value in "$@"; do
        int_value=$(float_to_int "$value")
        tensor+=("$int_value")
    done
}

# === Tensor anzeigen ===
print_tensor() {
    local -n tensor=$1
    for value in "${tensor[@]}"; do
        local negative=""
        if (( value < 0 )); then
            value=$(( -value ))
            negative="-"
        fi
        local int_part=$(( value / SCALE ))
        local frac_part=$(( value % SCALE ))
        printf "%s%d.%03d " "$negative" "$int_part" "$frac_part"
    done
    echo
}

# === Tensor Addition ===
add_tensors() {
    local -n result=$1
    local -n tensor_a=$2
    local -n tensor_b=$3
    result=()
    for i in "${!tensor_a[@]}"; do
        result+=($(( tensor_a[i] + tensor_b[i] )))
    done
}

# === Tensor Multiplikation (elementweise) ===
multiply_tensors() {
    local -n result=$1
    local -n tensor_a=$2
    local -n tensor_b=$3
    result=()
    for i in "${!tensor_a[@]}"; do
        result+=($(( tensor_a[i] * tensor_b[i] / SCALE )))
    done
}

# === Tests ===
run_tests() {
    echo "== Starte Tests =="

    create_tensor tensor1 1.234 5.678 9.001
    create_tensor tensor2 2.000 3.000 4.000

    echo "Tensor 1:"
    print_tensor tensor1
    echo "Erwartet: 1.234 5.678 9.001"

    echo "Tensor 2:"
    print_tensor tensor2
    echo "Erwartet: 2.000 3.000 4.000"

    add_tensors tensor_sum tensor1 tensor2
    echo "Summe:"
    print_tensor tensor_sum
    echo "Erwartet: 3.234 8.678 13.001"

    multiply_tensors tensor_product tensor1 tensor2
    echo "Produkt:"
    print_tensor tensor_product
    echo "Erwartet: 2.468 17.034 36.004"

    echo "== Tests abgeschlossen =="
}

# === Ausführung ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
