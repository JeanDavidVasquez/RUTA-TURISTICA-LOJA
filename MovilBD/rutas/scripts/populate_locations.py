import os
import sys
import django

# Setup Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Provincia, Canton, Parroquia

def populate():
    print("Iniciando carga de datos de ubicación...")

    # Estructura de datos: Provincia -> { Canton: [Parroquias] }
    data = {
        "Loja": {
            "Loja": [
                "El Sagrario", "San Sebastián", "Sucre", "El Valle", # Urbanas
                "Vilcabamba", "Malacatos", "El Cisne", "Chuquiribamba", "Santiago", "San Lucas", "Jimbilla", "Yangana", "Quinara", "Chantaco", "Gualel", "Taquil" # Rurales
            ],
            "Catamayo": [
                "Catamayo", "San Pedro de la Bendita", "El Tambo", "Guayquichuma", "Zambi"
            ],
            "Saraguro": [
                "Saraguro", "San Pablo de Tenta", "El Paraíso de Celén", "Urdaneta", "Lluzhapa", "Manú", "San Antonio de Q."
            ],
            "Paltas": [
                "Catacocha", "Guachanamá", "Lauro Guerrero", "Cangonamá"
            ],
            "Calvas": [
                "Cariamanga", "Utuana", "Sanguillín"
            ]
        }
    }

    for prov_name, cantones in data.items():
        provincia, created = Provincia.objects.get_or_create(nombre=prov_name)
        if created:
            print(f"✅ Provincia creada: {prov_name}")
        else:
            print(f"ℹ️ Provincia ya existe: {prov_name}")

        for canton_name, parroquias in cantones.items():
            canton, created = Canton.objects.get_or_create(nombre=canton_name, provincia=provincia)
            if created:
                print(f"  ✅ Cantón creado: {canton_name}")
            
            for parr_name in parroquias:
                parroquia, created = Parroquia.objects.get_or_create(nombre=parr_name, canton=canton)
                if created:
                    print(f"    ✅ Parroquia creada: {parr_name}")

    print("\n¡Carga de datos completada exitosamente!")

if __name__ == '__main__':
    populate()
