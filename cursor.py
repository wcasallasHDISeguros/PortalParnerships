import pyautogui
import time
import sys

# Tiempo de espera en segundos (2 minutos = 120 segundos)
INTERVALO = 120 

print("Script iniciado. Moviendo el mouse cada 2 minutos para mantener la sesión activa.")
print("Para detener el script, presiona Ctrl + C en la terminal.")

try:
    while True:
        # Espera los 2 minutos
        time.sleep(INTERVALO)
        
        # Mueve el mouse 5 píxeles a la derecha y 5 hacia abajo (movimiento relativo)
        pyautogui.moveRel(5, 5, duration=0.2)
        
        # Lo regresa a su posición original
        pyautogui.moveRel(-5, -5, duration=0.2)
        
        print("Mousse movido sutilmente para evitar suspensión.")

except KeyboardInterrupt:
    print("\nScript detenido por el usuario.")
    sys.exit()

