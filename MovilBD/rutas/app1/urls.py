from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()

router.register(r'usuarios', views.UsuarioViewSet, basename='usuario')
router.register(r'categorias', views.CategoriaViewSet, basename='categoria')
router.register(r'lugares', views.LugarViewSet, basename='lugar')
router.register(r'resenas', views.ResenaViewSet, basename='resena')
router.register(r'favoritos', views.FavoritoViewSet, basename='favorito')
router.register(r'eventos', views.EventoViewSet, basename='evento')
router.register(r'rutas', views.RutaViewSet, basename='ruta')
router.register(r'rutas-guardadas', views.Ruta_GuardadaViewSet, basename='rutaguardada')
router.register(r'ruta-lugares', views.Ruta_LugarViewSet, basename='rutalugar')


urlpatterns = [
    path('', include(router.urls)),
]