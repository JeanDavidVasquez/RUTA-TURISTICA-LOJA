import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Ruta, Ruta_Lugar, Lugar

def add_places():
    try:
        # 1. Buscar la ruta
        rutas = Ruta.objects.filter(nombre__icontains="Ruta Prueba")
        if not rutas.exists():
            print("No se encontró 'Ruta Prueba'")
            return
        ruta = rutas.first()

        # 2. Buscar lugares en Loja
        lugar1 = Lugar.objects.filter(nombre__icontains="Puerta de la Ciudad").first()
        lugar2 = Lugar.objects.filter(nombre__icontains="Parque Jipiro").first()
        lugar3 = Lugar.objects.filter(nombre__icontains="Vilcabamba").first()

        if not lugar1 or not lugar2:
            print("No se encontraron los lugares de ejemplo (Puerta de la Ciudad, Jipiro).")
            # Intentar buscar cualquier lugar
            lugares_random = Lugar.objects.all()[:3]
            if not lugares_random:
                print("No hay lugares en la BD.")
                return
            lugar1 = lugares_random[0]
            lugar2 = lugares_random[1] if len(lugares_random) > 1 else None
            lugar3 = lugares_random[2] if len(lugares_random) > 2 else None

        # 3. Asignar lugares a la ruta
        # Limpiar anteriores si quieres, o solo agregar
        # Ruta_Lugar.objects.filter(ruta=ruta).delete() 
        
        if lugar1:
            Ruta_Lugar.objects.get_or_create(ruta=ruta, lugar=lugar1, defaults={'orden': 1})
            print(f"Agregado: {lugar1.nombre}")
        
        if lugar2:
            Ruta_Lugar.objects.get_or_create(ruta=ruta, lugar=lugar2, defaults={'orden': 2})
            print(f"Agregado: {lugar2.nombre}")

        if lugar3:
            Ruta_Lugar.objects.get_or_create(ruta=ruta, lugar=lugar3, defaults={'orden': 3})
            print(f"Agregado: {lugar3.nombre}")

        print("Lugares agregados exitosamente a Ruta Prueba.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    add_places()
