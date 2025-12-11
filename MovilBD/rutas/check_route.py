import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Ruta, Ruta_Lugar

def check_route():
    try:
        # Buscar la ruta "Ruta Prueba"
        rutas = Ruta.objects.filter(nombre__icontains="Ruta Prueba")
        if not rutas.exists():
            print("No se encontró ninguna ruta llamada 'Ruta Prueba'")
            return

        for ruta in rutas:
            print(f"Ruta: {ruta.nombre} (ID: {ruta.id})")
            lugares = Ruta_Lugar.objects.filter(ruta=ruta).order_by('orden')
            if lugares.exists():
                print(f"  Tiene {lugares.count()} lugares:")
                for rl in lugares:
                    print(f"    - [{rl.orden}] Lugar ID: {rl.lugar.id} (Nombre: {rl.lugar.nombre})")
            else:
                print("  NO tiene lugares asignados.")
                
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    check_route()
