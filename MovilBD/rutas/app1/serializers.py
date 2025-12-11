from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import (
    Usuario, Resena, Categoria, Lugar, 
    Favorito, Evento, Ruta, Ruta_Guardada, Ruta_Lugar
)

# --- Serializadores Base ---

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'nombreDisplay', 'varFoto', 'fechaCreacion', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        password = validated_data.pop('password')
        usuario = Usuario(**validated_data)
        usuario.password = make_password(password)
        usuario.save()
        return usuario

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = '__all__'

# --- Serializadores con Relaciones ---

class LugarSerializer(serializers.ModelSerializer):
    categorias = CategoriaSerializer(many=True, read_only=True)
    
    # Campos de ubicación jerárquica (solo lectura)
    provincia_nombre = serializers.CharField(source='ubicacion.canton.provincia.nombre', read_only=True, default="-")
    canton_nombre = serializers.CharField(source='ubicacion.canton.nombre', read_only=True, default="-")
    parroquia_nombre = serializers.CharField(source='ubicacion.nombre', read_only=True, default="-")

    class Meta:
        model = Lugar
        fields = [
            'id', 'nombre', 'descripcion', 'latitud', 'longitud', 
            'direccionCompleta', 'provincia', 'canton', 'parroquia', 
            'provincia_nombre', 'canton_nombre', 'parroquia_nombre',
            'horarios', 'contacto', 'urlImagenPrincipal', 
            'categorias'
        ]
            
class ResenaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)
    
    class Meta:
        model = Resena
        fields = [
            'id', 'texto', 'calificacion', 'fechaCreacion', 
            'lugar', 'lugar_nombre', 'ruta', 'ruta_nombre', 
            'usuario', 'usuario_username'
        ]

class FavoritoSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Favorito
        fields = [
            'id', 'fechaGuardado', 'usuario', 'usuario_username', 
            'lugar', 'lugar_nombre', 'tipo'
        ]

class EventoSerializer(serializers.ModelSerializer):
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Evento
        fields = [
            'id', 'nombre', 'descripcion', 'urlImagen', 'fechaEvento', 
            'categoriaEvento', 'direccionAlternativa', 
            'lugar', 'lugar_nombre'
        ]

class RutaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    categorias = CategoriaSerializer(many=True, read_only=True)
    num_guardados = serializers.IntegerField(read_only=True)
    
    # Campo calculado
    tiempo_total_estimado = serializers.IntegerField(read_only=True)

    class Meta:
        model = Ruta
        fields = [
            'id', 'nombre', 'descripcion', 'visibilidadRuta', 
            'urlImagenPortada', 'fechaCreacion', 'duracionEstimadaSeg', 
            'distanciaEstimadaKm', 'usuario', 'usuario_username',
            'categorias', 'num_guardados', 'tiempo_total_estimado'
        ]

class Ruta_GuardadaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import (
    Usuario, Resena, Categoria, Lugar, 
    Favorito, Evento, Ruta, Ruta_Guardada, Ruta_Lugar
)

# --- Serializadores Base ---

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'nombreDisplay', 'varFoto', 'fechaCreacion', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        password = validated_data.pop('password')
        usuario = Usuario(**validated_data)
        usuario.password = make_password(password)
        usuario.save()
        return usuario

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = '__all__'

# --- Serializadores con Relaciones ---

class LugarSerializer(serializers.ModelSerializer):
    categorias = CategoriaSerializer(many=True, read_only=True)
    
    # Campos de ubicación jerárquica (solo lectura)
    provincia_nombre = serializers.CharField(source='ubicacion.canton.provincia.nombre', read_only=True, default="-")
    canton_nombre = serializers.CharField(source='ubicacion.canton.nombre', read_only=True, default="-")
    parroquia_nombre = serializers.CharField(source='ubicacion.nombre', read_only=True, default="-")

    class Meta:
        model = Lugar
        fields = [
            'id', 'nombre', 'descripcion', 'latitud', 'longitud', 
            'direccionCompleta', 'provincia', 'canton', 'parroquia', 
            'provincia_nombre', 'canton_nombre', 'parroquia_nombre',
            'horarios', 'contacto', 'urlImagenPrincipal', 
            'categorias'
        ]
            
class ResenaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)
    
    class Meta:
        model = Resena
        fields = [
            'id', 'texto', 'calificacion', 'fechaCreacion', 
            'lugar', 'lugar_nombre', 'ruta', 'ruta_nombre', 
            'usuario', 'usuario_username'
        ]

class FavoritoSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Favorito
        fields = [
            'id', 'fechaGuardado', 'usuario', 'usuario_username', 
            'lugar', 'lugar_nombre', 'tipo'
        ]

class EventoSerializer(serializers.ModelSerializer):
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Evento
        fields = [
            'id', 'nombre', 'descripcion', 'urlImagen', 'fechaEvento', 
            'categoriaEvento', 'direccionAlternativa', 
            'lugar', 'lugar_nombre'
        ]

class RutaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    categorias = CategoriaSerializer(many=True, read_only=True)
    num_guardados = serializers.IntegerField(read_only=True)
    
    # Campo calculado
    tiempo_total_estimado = serializers.IntegerField(read_only=True)

    class Meta:
        model = Ruta
        fields = [
            'id', 'nombre', 'descripcion', 'visibilidadRuta', 
            'urlImagenPortada', 'fechaCreacion', 'duracionEstimadaSeg', 
            'distanciaEstimadaKm', 'usuario', 'usuario_username',
            'categorias', 'num_guardados', 'tiempo_total_estimado'
        ]

class Ruta_GuardadaSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)

    class Meta:
        model = Ruta_Guardada
        fields = [
            'id', 'orden', 'fechaGuardado', 'usuario', 'usuario_username', 
            'ruta', 'ruta_nombre'
        ]

class Ruta_LugarSerializer(serializers.ModelSerializer):
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    
    class Meta:
        model = Ruta_Lugar
        fields = [
            'id', 'orden', 'fechaGuardado', 'ruta', 'ruta_nombre', 
            'lugar', 'lugar_nombre', 'tiempo_sugerido_minutos', 'comentario'
        ]