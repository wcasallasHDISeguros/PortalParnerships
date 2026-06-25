import pyautogui
import time
import sys

INTERVALO = 240  # 2 minutos

print("Script optimizado iniciado. Presionando tecla invisible cada 2 minutos.")
print("Para detener el script, presiona Ctrl + C.")

try:
    while True:
        time.sleep(INTERVALO)
        
        # F15 es una tecla real en Windows pero no tiene ninguna función asignada,
        # así que no interrumpirá lo que estés escribiendo o haciendo.
        pyautogui.press('f15')
        
        print("Señor de actividad enviado a Windows (F15).")

except KeyboardInterrupt:
    print("\nScript detenido por el usuario.")
    sys.exit()

