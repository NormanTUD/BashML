#!/bin/bash

source ./tensor_nn.sh

mse_loss() {
    local -n predictions=$1
    local -n targets=$2
    local size="${#predictions[@]}"
    local sum=0
    local diff
    local sq
    for ((i=0; i<size; i++)); do
        diff=$(( predictions[i] - targets[i] ))
        sq=$(( diff * diff / SCALE ))
        sum=$(( sum + sq ))
    done
    echo $(( sum / size ))
}

gradient_step() {
    local -n weights=$1
    local -n gradients=$2
    local learning_rate="$3"
    local size="${#weights[@]}"
    for ((i=0; i<size; i++)); do
        weights[i]=$(( weights[i] - (gradients[i] * learning_rate / SCALE) ))
    done
}

dummy_backprop() {
    local -n predictions=$1
    local -n targets=$2
    local -n gradients=$3
    local size="${#predictions[@]}"
    gradients=()
    for ((i=0; i<size; i++)); do
        gradients+=($(( 2 * (predictions[i] - targets[i]) )))
    done
}

run_training() {
    echo "== Starte Training =="

    create_tensor2d input rows_in cols_in 1 3 1.0 2.0 3.0
    create_tensor2d weights rows_w cols_w 3 2 0.5 0.2 0.8 0.4 0.3 0.9
    create_tensor2d bias rows_b cols_b 1 2 0.1 0.2
    create_tensor2d target_output rows_t cols_t 1 2 5.0 7.0

    learning_rate=100  # Entspricht 0.1

    for epoch in {1..5}; do
        matrix_multiply layer_output input "$rows_in" "$cols_in" weights "$rows_w" "$cols_w"
        add_tensors2d layer_output_with_bias layer_output bias
        relu_tensor2d predictions layer_output_with_bias

        loss=$(mse_loss predictions target_output)
        echo "Epoch $epoch - Loss: "
        print_value "$loss"
        echo

        dummy_backprop predictions target_output gradients
        gradient_step weights gradients "$learning_rate"
    done

    echo "== Training abgeschlossen =="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_training
fi
