from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import (
    Usuario, Resena, Categoria, Lugar, 
    Favorito, Evento, Ruta, Ruta_Guardada, Ruta_Lugar,
    Publicacion, AdministradorLugar, Comentario,
    Provincia, Canton, Parroquia
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

# --- Serializadores de Ubicación Jerárquica ---

class ProvinciaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Provincia
        fields = ['id', 'nombre']

class CantonSerializer(serializers.ModelSerializer):
    provincia_nombre = serializers.CharField(source='provincia.nombre', read_only=True)
    
    class Meta:
        model = Canton
        fields = ['id', 'nombre', 'provincia', 'provincia_nombre']

class ParroquiaSerializer(serializers.ModelSerializer):
    canton_nombre = serializers.CharField(source='canton.nombre', read_only=True)
    provincia_nombre = serializers.CharField(source='canton.provincia.nombre', read_only=True)
    
    class Meta:
        model = Parroquia
        fields = ['id', 'nombre', 'canton', 'canton_nombre', 'provincia_nombre']

class LugarSerializer(serializers.ModelSerializer):
    categorias = CategoriaSerializer(many=True, read_only=True)
    
    # Campos calculados para rating
    rating_promedio = serializers.SerializerMethodField()
    num_resenas = serializers.SerializerMethodField()
    
    # Campos de ubicación con fallback a FK
    provincia = serializers.SerializerMethodField()
    canton = serializers.SerializerMethodField()
    parroquia = serializers.SerializerMethodField()

    class Meta:
        model = Lugar
        fields = [
            'id', 'nombre', 'descripcion', 'latitud', 'longitud', 
            'direccionCompleta', 'provincia', 'canton', 'parroquia', 
            'horarios', 'contacto', 'urlImagenPrincipal', 
            'categorias', 'rating_promedio', 'num_resenas'
        ]
    
    def get_provincia(self, obj):
        # Primero intenta FK, luego campo de texto
        if obj.ubicacion and obj.ubicacion.canton and obj.ubicacion.canton.provincia:
            return obj.ubicacion.canton.provincia.nombre
        return obj.provincia if obj.provincia and len(obj.provincia) > 1 else None
    
    def get_canton(self, obj):
        if obj.ubicacion and obj.ubicacion.canton:
            return obj.ubicacion.canton.nombre
        return obj.canton if obj.canton and len(obj.canton) > 1 else None
    
    def get_parroquia(self, obj):
        if obj.ubicacion:
            return obj.ubicacion.nombre
        return obj.parroquia if obj.parroquia and len(obj.parroquia) > 1 else None
    
    def get_rating_promedio(self, obj):
        from django.db.models import Avg
        promedio = obj.resenas.aggregate(avg=Avg('calificacion'))['avg']
        return round(promedio, 1) if promedio else 0.0
    
    def get_num_resenas(self, obj):
        return obj.resenas.count()
            
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

# --- NUEVOS SERIALIZADORES (Social) ---

class PublicacionSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    usuario_foto = serializers.CharField(source='usuario.varFoto', read_only=True) # Para mostrar avatar
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    es_propietario = serializers.SerializerMethodField()

    class Meta:
        model = Publicacion
        fields = [
            'id', 'usuario', 'usuario_username', 'usuario_foto',
            'lugar', 'lugar_nombre',
            'tipo', 'archivo_media', 'descripcion', 'fecha', 'es_visible',
            'es_propietario'
        ]
        read_only_fields = ['fecha', 'es_visible', 'es_propietario'] 

    def get_es_propietario(self, obj):
        # Verifica si el autor de la publicacion administra el lugar
        from .models import AdministradorLugar
        return AdministradorLugar.objects.filter(usuario=obj.usuario, lugar=obj.lugar).exists() 

class AdministradorLugarSerializer(serializers.ModelSerializer):
    lugar_nombre = serializers.CharField(source='lugar.nombre', read_only=True)
    
    class Meta:
        model = AdministradorLugar
        fields = ['id', 'usuario', 'lugar', 'lugar_nombre', 'fecha_asignacion']

class ComentarioSerializer(serializers.ModelSerializer):
    usuario_username = serializers.CharField(source='usuario.username', read_only=True)
    usuario_foto = serializers.CharField(source='usuario.varFoto', read_only=True)
    
    class Meta:
        model = Comentario
        fields = '__all__'