import csv
import re

with open('datos_pollitos_latest_copy.sql', 'r', encoding='utf-8') as f:
    contenido = f.read()

# Extraer todas las tuplas de valores
patron = r"\(([^)]+)\)"
lineas = re.findall(patron, contenido)

datos_procesados = []
for linea in lineas:
    # Dividir por comas, pero respetando comas dentro de strings
    campos = []
    campo_actual = ""
    dentro_comillas = False
    dentro_parentesis = False
    
    for char in linea:
        if char == "'" and not dentro_parentesis:
            dentro_comillas = not dentro_comillas
            campo_actual += char
        elif char == '(':
            dentro_parentesis = True
        elif char == ')':
            dentro_parentesis = False
        elif char == ',' and not dentro_comillas and not dentro_parentesis:
            campos.append(campo_actual.strip())
            campo_actual = ""
        else:
            campo_actual += char
    
    if campo_actual:
        campos.append(campo_actual.strip())
    
    # Limpiar comillas y NULL
    campos_limpios = []
    for campo in campos:
        if campo == "NULL":
            campos_limpios.append("")
        elif campo.startswith("'") and campo.endswith("'"):
            campos_limpios.append(campo[1:-1])
        else:
            campos_limpios.append(campo)
    
    datos_procesados.append(campos_limpios)

# Escribir CSV
with open('datos_pollitos_latest.csv', 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(datos_procesados)

print(f"Convertidas {len(datos_procesados)} filas a .csv")