#!/usr/bin/env bash
# Executar a partir da pasta Guia_Logica_Digital/
xrun -64bit -sv -access +rwc -gui \
    modelos/controlador_temporizado.sv \
    modelos/tb_controlador_temporizado.sv \
    -top tb_controlador_temporizado
