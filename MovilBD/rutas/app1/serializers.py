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
        # Lista explícita de campos. 'password' se incluye para la creación.
        fields = ['id', 'username', 'email', 'nombreDisplay', 'varFoto', 'fechaCreacion', 'password']
        extra_kwargs = {
            'password': {'write_only': True} # Asegura que la contraseña no se devuelva en peticiones GET
        }

    def create(self, validated_data):
        # Saca la contraseña del diccionario de datos
        password = validated_data.pop('password')
        
        # Crea la instancia del usuario sin la contraseña
        usuario = Usuario(**validated_data)
        
        # Usa make_password() para hashear la contraseña manualmente
        usuario.password = make_password(password)
        
        # Guarda el usuario en la base de datos
        usuario.save()
        return usuario

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = '__all__' # Incluye todos los campos del modelo

# --- Serializadores con Relaciones ---

class LugarSerializer(serializers.ModelSerializer):
    # categorias es ManyToMany. Incluimos los detalles de las categorías.
    categorias = CategoriaSerializer(many=True, read_only=True)
    
    # Para escritura, si quisieras enviar IDs de categorías, podrías necesitar otro campo
    # o usar PrimaryKeyRelatedField. Por ahora lo dejamos así para visualización.

    class Meta:
        model = Lugar
        fields = [
            'id', 'nombre', 'descripcion', 'latitud', 'longitud', 
            'direccionCompleta', 'provincia', 'canton', 'parroquia', 
            'horarios', 'contacto', 'urlImagenPrincipal', 
            'categorias'
        ]
            
class ResenaSerializer(serializers.ModelSerializer):
    # Campos de solo lectura para dar contexto
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    
    class Meta:
        model = Resena
        fields = [
            'id', 'texto', 'calificacion', 'fechaCreacion', 
            'lugar', 'lugar_nombre', 'usuario', 'usuario_username'
        ]

class FavoritoSerializer(serializers.ModelSerializer):
    # Campos de solo lectura para dar contexto
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Favorito
        fields = [
            'id', 'fechaGuardado', 'usuario', 'usuario_username', 
            'lugar', 'lugar_nombre', 'tipo'
        ]
        # DRF maneja la validación de 'unique_together' automáticamente

class EventoSerializer(serializers.ModelSerializer):
    # Campo de solo lectura para dar contexto
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)

    class Meta:
        model = Evento
        fields = [
            'id', 'nombre', 'descripcion', 'urlImagen', 'fechaEvento', 
            'categoriaEvento', 'direccionAlternativa', 
            'lugar', 'lugar_nombre'
        ]

class RutaSerializer(serializers.ModelSerializer):
    # Campo de solo lectura para dar contexto
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    categorias = CategoriaSerializer(many=True, read_only=True)
    
    # Campo calculado en el ViewSet
    num_guardados = serializers.IntegerField(read_only=True)

    class Meta:
        model = Ruta
        fields = [
            'id', 'nombre', 'descripcion', 'visibilidadRuta', 
            'urlImagenPortada', 'fechaCreacion', 'duracionEstimadaSeg', 
            'distanciaEstimadaKm', 'usuario', 'usuario_username',
            'categorias', 'num_guardados'
        ]

class Ruta_GuardadaSerializer(serializers.ModelSerializer):
    # Campos de solo lectura para dar contexto
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)

    class Meta:
        model = Ruta_Guardada
        fields = [
            'id', 'orden', 'fechaGuardado', 'usuario', 'usuario_username', 
            'ruta', 'ruta_nombre'
        ]

class Ruta_LugarSerializer(serializers.ModelSerializer):
    # Campos de solo lectura para dar contexto
    ruta_nombre = serializers.CharField(source='ruta.nombre', read_only=True)
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    
    class Meta:
        model = Ruta_Lugar
        fields = [
            'id', 'orden', 'fechaGuardado', 'ruta', 'ruta_nombre', 
            'lugar', 'lugar_nombre'
        ]