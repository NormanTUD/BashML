#!/bin/bash

source ./tensor_nn.sh

# Mean Squared Error Loss (MSE)
mse_loss() {
    local predictions=("${!1}")
    local targets=("${!2}")
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

# Gradient Step (Aktualisierung der Gewichte mit Gradienten)
gradient_step() {
    local weights=("${!1}")
    local gradients=("${!2}")
    local learning_rate="$3"
    local size="${#weights[@]}"
    local updated_value
    for ((i=0; i<size; i++)); do
        updated_value=$(( weights[i] - (gradients[i] * learning_rate / SCALE) ))
        weights[i]=$updated_value
    done
}

# Backpropagation (Berechnung der Gradienten)
dummy_backprop() {
    local predictions=("${!1}")
    local targets=("${!2}")
    local gradients=()
    local size="${#predictions[@]}"
    for ((i=0; i<size; i++)); do
        gradients[$i]=$(( 2 * (predictions[i] - targets[i]) ))
    done
    echo "${gradients[@]}"
}

run_training() {
    echo "== Starte Training =="

    # Initialisierung von Tensoren
    create_tensor2d input rows_in cols_in 1 3 1.0 2.0 3.0
    create_tensor2d weights rows_w cols_w 3 2 0.5 0.2 0.8 0.4 0.3 0.9
    create_tensor2d bias rows_b cols_b 1 2 0.1 0.2
    create_tensor2d target_output rows_t cols_t 1 2 5.0 7.0

    # Lernrate
    learning_rate=10  # Entspricht einer Lernrate von 0.1

    for epoch in {1..5}; do
        # Forward Pass
        matrix_multiply layer_output input "$rows_in" "$cols_in" weights "$rows_w" "$cols_w"
        add_tensors2d layer_output_with_bias layer_output bias
        relu_tensor2d predictions layer_output_with_bias

        # Debugging: Ausgabe von Eingaben, Gewichten und Vorhersagen
        echo "Epoch $epoch - Vorhersagen (predictions): ${predictions[@]}"
        echo "Eingabewerte (input): ${input[@]}"
        echo "Gewichte (weights): ${weights[@]}"
        echo "Bias: ${bias[@]}"
        echo "Layer Output (mit Bias): ${layer_output_with_bias[@]}"

        # Berechnung des Loss
        loss=$(mse_loss predictions target_output)
        echo "Loss: $loss"
        echo

        # Backpropagation (Dummy)
        output_gradients=$(dummy_backprop predictions target_output)

        # Gradienten als Array umwandeln
        gradients=($output_gradients)

        # Debugging: Ausgabe der Gradienten
        echo "Gradients: ${gradients[@]}"

        # Gradientenabstieg
        gradient_step weights gradients "$learning_rate"

        # Debugging: Ausgabe der aktualisierten Gewichte
        echo "Aktualisierte Gewichte: ${weights[@]}"
        echo
    done

    echo "== Training abgeschlossen =="
}

# Starte Training, wenn das Skript direkt ausgeführt wird
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_training
fi
