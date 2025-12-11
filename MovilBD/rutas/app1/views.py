from django.shortcuts import render
from rest_framework import viewsets
from .models import *
from .serializers import *
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth.hashers import check_password
from django.http import JsonResponse
from django.db.models import Count

class UsuarioViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Usuarios.
    """
    queryset = Usuario.objects.all().order_by('-fechaCreacion')
    serializer_class = UsuarioSerializer

    @action(detail=False, methods=['post'])
    def login(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')
        
        usuario = None
        try:
            if username:
                usuario = Usuario.objects.get(username=username)
            elif email:
                usuario = Usuario.objects.get(email=email)
        except Usuario.DoesNotExist:
            return Response({'error': 'Credenciales inválidas'}, status=401)
            
        if usuario and check_password(password, usuario.password):
            serializer = UsuarioSerializer(usuario)
            return Response({'status': 'success', 'user': serializer.data})
        else:
            return Response({'error': 'Credenciales inválidas'}, status=401)

    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        usuario = self.get_object()
        # Contar favoritos (tipo='FAV')
        fav_count = Favorito.objects.filter(usuario=usuario, tipo='FAV').count()
        # Contar visitados (tipo='VISIT')
        visit_count = Favorito.objects.filter(usuario=usuario, tipo='VISIT').count()
        # Contar rutas creadas
        route_count = Ruta.objects.filter(usuario=usuario).count()
        
        return Response({
            'favoritos': fav_count,
            'visitados': visit_count,
            'rutas': route_count
        })

class CategoriaViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Categorias.
    """
    queryset = Categoria.objects.all()
    serializer_class = CategoriaSerializer

class LugarViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Lugares.
    """
    queryset = Lugar.objects.all()
    serializer_class = LugarSerializer

class ResenaViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Reseñas (Reviews).
    """
    queryset = Resena.objects.all().order_by('-fechaCreacion')
    serializer_class = ResenaSerializer

    def get_queryset(self):
        queryset = Resena.objects.all().order_by('-fechaCreacion')
        lugar_id = self.request.query_params.get('lugar')
        ruta_id = self.request.query_params.get('ruta')
        usuario_id = self.request.query_params.get('usuario')

        if lugar_id:
            queryset = queryset.filter(lugar__id=lugar_id)
        if ruta_id:
            queryset = queryset.filter(ruta__id=ruta_id)
        if usuario_id:
            queryset = queryset.filter(usuario__id=usuario_id)
            
        return queryset

class FavoritoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Favoritos.
    """
    queryset = Favorito.objects.all()
    serializer_class = FavoritoSerializer

    def get_queryset(self):
        queryset = Favorito.objects.all()
        usuario_id = self.request.query_params.get('usuario')
        lugar_id = self.request.query_params.get('lugar')
        tipo = self.request.query_params.get('tipo')

        if usuario_id:
            queryset = queryset.filter(usuario__id=usuario_id)
        if lugar_id:
            queryset = queryset.filter(lugar__id=lugar_id)
        if tipo:
            queryset = queryset.filter(tipo=tipo)
            
        return queryset

class EventoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Eventos.
    """
    queryset = Evento.objects.all().order_by('fechaEvento')
    serializer_class = EventoSerializer

class RutaViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Rutas.
    """
    queryset = Ruta.objects.all().order_by('-fechaCreacion')
    serializer_class = RutaSerializer

    def get_queryset(self):
        from django.db.models import Count
        return Ruta.objects.annotate(
            num_guardados=Count('ruta_guardada')
        ).order_by('-fechaCreacion')

class Ruta_GuardadaViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite ver y editar Rutas Guardadas por usuarios.
    """
    queryset = Ruta_Guardada.objects.all()
    serializer_class = Ruta_GuardadaSerializer

    def get_queryset(self):
        queryset = Ruta_Guardada.objects.all()
        usuario_id = self.request.query_params.get('usuario')
        ruta_id = self.request.query_params.get('ruta')

        if usuario_id:
            queryset = queryset.filter(usuario__id=usuario_id)
        if ruta_id:
            queryset = queryset.filter(ruta__id=ruta_id)
            
        return queryset

class Ruta_LugarViewSet(viewsets.ModelViewSet):
    """
    API endpoint que gestiona los lugares dentro de una ruta.
    Permite filtrar por 'ruta' (ID de la ruta) para obtener los puntos ordenados.
    Ej: /api/ruta-lugares/?ruta=1
    """
    queryset = Ruta_Lugar.objects.all()
    serializer_class = Ruta_LugarSerializer

    def get_queryset(self):
        queryset = Ruta_Lugar.objects.all()
        ruta_id = self.request.query_params.get('ruta')
        if ruta_id is not None:
            queryset = queryset.filter(ruta__id=ruta_id).order_by('orden')
        return queryset

# --- AJAX VIEWS FOR ADMIN ---
def load_cantones(request):
    provincia_id = request.GET.get('provincia')
    cantones = Canton.objects.filter(provincia_id=provincia_id).order_by('nombre')
    return JsonResponse(list(cantones.values('id', 'nombre')), safe=False)

def load_parroquias(request):
    canton_id = request.GET.get('canton')
    parroquias = Parroquia.objects.filter(canton_id=canton_id).order_by('nombre')
    return JsonResponse(list(parroquias.values('id', 'nombre')), safe=False)