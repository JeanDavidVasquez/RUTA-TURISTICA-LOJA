import os
import django
import random
from datetime import timedelta
from django.utils import timezone

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Usuario, Categoria, Lugar, Ruta, Ruta_Lugar, Ruta_Guardada, Favorito

def populate():
    print("Iniciando población de datos...")

    # 1. Crear Usuarios
    print("Creando usuarios...")
    admin_user, _ = Usuario.objects.get_or_create(
        username='admin',
        defaults={
            'email': 'admin@example.com',
            'password': 'adminpassword',
            'nombreDisplay': 'Administrador del Sistema',
            'varFoto': 'https://ui-avatars.com/api/?name=Admin&background=0D8ABC&color=fff'
        }
    )

    demo_user, _ = Usuario.objects.get_or_create(
        username='usuario_demo',
        defaults={
            'email': 'demo@example.com',
            'password': 'demopassword',
            'nombreDisplay': 'Usuario Demo',
            'varFoto': 'https://ui-avatars.com/api/?name=Usuario+Demo&background=random'
        }
    )

    # 2. Crear Categorías
    print("Creando categorías...")
    categorias_data = [
        ('Senderismo', 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=500', 'directions_walk'),
        ('Cultura', 'https://images.unsplash.com/photo-1560264357-8d9202250f21?w=500', 'museum'),
        ('Gastronomía', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500', 'restaurant'),
        ('Naturaleza', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500', 'nature'),
        ('Religioso', 'https://images.unsplash.com/photo-1548625361-988230079b38?w=500', 'church'),
    ]

    categorias_objs = {}
    for nombre, img, icon in categorias_data:
        cat, _ = Categoria.objects.get_or_create(
            nombre=nombre,
            defaults={'urlImagen': img, 'urlIcono': icon}
        )
        categorias_objs[nombre] = cat

    # 3. Crear Lugares
    print("Creando lugares...")
    lugares_data = [
        {
            'nombre': 'Parque Jipiro',
            'descripcion': 'Un parque recreacional con réplicas de monumentos mundiales.',
            'latitud': -3.9713, 'longitud': -79.2045,
            'direccion': 'Av. Salvador Bustamante Celi',
            'img': 'https://images.unsplash.com/photo-1596423736766-339c9404225d?w=500',
            'cats': ['Naturaleza', 'Cultura']
        },
        {
            'nombre': 'Puerta de la Ciudad',
            'descripcion': 'Monumento icónico de Loja, entrada al centro histórico.',
            'latitud': -3.9876, 'longitud': -79.2048,
            'direccion': 'Av. Gran Colombia',
            'img': 'https://images.unsplash.com/photo-1590606906886-444c9292394c?w=500',
            'cats': ['Cultura']
        },
        {
            'nombre': 'Calle Lourdes',
            'descripcion': 'Calle colonial colorida llena de artesanías y cafeterías.',
            'latitud': -3.9980, 'longitud': -79.2030,
            'direccion': 'Calle Lourdes',
            'img': 'https://images.unsplash.com/photo-1574950578143-858c6fc58922?w=500',
            'cats': ['Cultura', 'Gastronomía']
        },
        {
            'nombre': 'Mirador El Turi (Cuenca)', # Un poco lejos pero para demo
            'descripcion': 'Vista panorámica de la ciudad.',
            'latitud': -2.9367, 'longitud': -79.0053,
            'direccion': 'Turi',
            'img': 'https://images.unsplash.com/photo-1564426863-71881747864e?w=500',
            'cats': ['Naturaleza']
        },
        {
            'nombre': 'Catedral de Loja',
            'descripcion': 'Iglesia principal ubicada en el parque central.',
            'latitud': -3.9955, 'longitud': -79.2035,
            'direccion': 'Parque Central',
            'img': 'https://images.unsplash.com/photo-1548625361-988230079b38?w=500',
            'cats': ['Religioso', 'Cultura']
        },
    ]

    lugares_objs = []
    for l_data in lugares_data:
        lugar, created = Lugar.objects.get_or_create(
            nombre=l_data['nombre'],
            defaults={
                'descripcion': l_data['descripcion'],
                'latitud': l_data['latitud'],
                'longitud': l_data['longitud'],
                'direccionCompleta': l_data['direccion'],
                'urlImagenPrincipal': l_data['img'],
                'provincia': 'Loja',
                'canton': 'Loja'
            }
        )
        if created:
            for cat_name in l_data['cats']:
                if cat_name in categorias_objs:
                    lugar.categorias.add(categorias_objs[cat_name])
        lugares_objs.append(lugar)

    # 4. Crear Rutas
    print("Creando rutas...")

    # Ruta 1: Admin - Ruta Cultural (Pública)
    ruta_admin, _ = Ruta.objects.get_or_create(
        nombre="Ruta Cultural de Loja",
        usuario=admin_user,
        defaults={
            'descripcion': "Recorrido por los principales hitos culturales de la ciudad.",
            'visibilidadRuta': 'publica',
            'urlImagenPortada': 'https://images.unsplash.com/photo-1590606906886-444c9292394c?w=500',
            'duracionEstimadaSeg': 7200, # 2 horas
            'distanciaEstimadaKm': 3.5,
        }
    )
    # Asociar lugares a ruta admin
    if Ruta_Lugar.objects.filter(ruta=ruta_admin).count() == 0:
        Ruta_Lugar.objects.create(ruta=ruta_admin, lugar=lugares_objs[1], orden=1) # Puerta
        Ruta_Lugar.objects.create(ruta=ruta_admin, lugar=lugares_objs[4], orden=2) # Catedral
        Ruta_Lugar.objects.create(ruta=ruta_admin, lugar=lugares_objs[2], orden=3) # Lourdes
    
    # Asociar categorías a ruta admin
    ruta_admin.categorias.add(categorias_objs['Cultura'])


    # Ruta 2: Admin - Ruta de Parques (Pública)
    ruta_parques, _ = Ruta.objects.get_or_create(
        nombre="Ruta de los Parques",
        usuario=admin_user,
        defaults={
            'descripcion': "Disfruta del aire libre en los mejores parques.",
            'visibilidadRuta': 'publica',
            'urlImagenPortada': 'https://images.unsplash.com/photo-1596423736766-339c9404225d?w=500',
            'duracionEstimadaSeg': 3600,
            'distanciaEstimadaKm': 2.0,
        }
    )
    if Ruta_Lugar.objects.filter(ruta=ruta_parques).count() == 0:
        Ruta_Lugar.objects.create(ruta=ruta_parques, lugar=lugares_objs[0], orden=1) # Jipiro
    
    ruta_parques.categorias.add(categorias_objs['Naturaleza'])


    # Ruta 3: Usuario Demo - Mi Caminata (Privada/Pública)
    ruta_demo, _ = Ruta.objects.get_or_create(
        nombre="Mi caminata de domingo",
        usuario=demo_user,
        defaults={
            'descripcion': "Ruta personal para ejercicios.",
            'visibilidadRuta': 'privada',
            'urlImagenPortada': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500',
            'duracionEstimadaSeg': 1800,
            'distanciaEstimadaKm': 1.5,
        }
    )
    if Ruta_Lugar.objects.filter(ruta=ruta_demo).count() == 0:
        Ruta_Lugar.objects.create(ruta=ruta_demo, lugar=lugares_objs[0], orden=1) # Jipiro
    
    ruta_demo.categorias.add(categorias_objs['Senderismo'])


    # 5. Guardar Rutas (Admin routes saved by Demo user)
    print("Guardando rutas predeterminadas para usuario demo...")
    
    # Guardar la ruta cultural del admin en el perfil del usuario demo
    Ruta_Guardada.objects.get_or_create(
        usuario=demo_user,
        ruta=ruta_admin,
        defaults={'orden': 1}
    )
    
    # Guardar la ruta de parques
    Ruta_Guardada.objects.get_or_create(
        usuario=demo_user,
        ruta=ruta_parques,
        defaults={'orden': 2}
    )

    # 6. Crear Favoritos para Demo User
    print("Creando favoritos...")
    Favorito.objects.get_or_create(usuario=demo_user, lugar=lugares_objs[2], tipo='FAV') # Lourdes
    Favorito.objects.get_or_create(usuario=demo_user, lugar=lugares_objs[3], tipo='PEND') # Turi

    print("¡Datos poblados exitosamente!")

if __name__ == '__main__':
    populate()
