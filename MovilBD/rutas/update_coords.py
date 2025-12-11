import os
import django

# Configurar el entorno de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Lugar

def update_coordinates():
    updates = {
        "Parque Nacional Cajas": (-2.8528952, -79.2629718),
        "Ingapirca": (-2.5460564, -78.875772),
        "Puerta de la Ciudad": (-3.98954, -79.20416),
        "Parque Jipiro": (-3.97167, -79.20446),
        "Vilcabamba": (-4.263, -79.222),
        "Santuario de El Cisne": (-3.85101, -79.42649),
        "Calle Lourdes": (-3.998, -79.202), # Approx Loja
        "Jardín Botánico Reinaldo Espinosa": (-4.032, -79.203), # Approx Loja
        "Mirador de El Turi": (-2.925, -79.006), # Cuenca
        "Catedral Nueva de Cuenca": (-2.897, -79.005), # Cuenca
    }

    print("Actualizando coordenadas...")
    for nombre, coords in updates.items():
        try:
            # Buscar por nombre (case insensitive contains para ser más flexible)
            lugares = Lugar.objects.filter(nombre__icontains=nombre)
            if lugares.exists():
                for lugar in lugares:
                    lugar.latitud = coords[0]
                    lugar.longitud = coords[1]
                    lugar.save()
                    print(f"Actualizado: {lugar.nombre} -> {coords}")
            else:
                print(f"No encontrado: {nombre}")
        except Exception as e:
            print(f"Error actualizando {nombre}: {e}")

    print("Proceso completado.")

if __name__ == '__main__':
    update_coordinates()
