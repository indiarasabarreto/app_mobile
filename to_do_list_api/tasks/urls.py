from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TaskViewSet

# O roteador cria automaticamente as rotas para o seu TaskViewSet
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')

urlpatterns = [
    path('', include(router.urls)),
]