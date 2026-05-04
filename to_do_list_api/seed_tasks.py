import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'to_do_list_api.settings')
django.setup()

from tasks.models import Task

def seed_tasks():
    print("Starting to seed tasks...")
    
    # Cleaning existing tasks to avoid duplicates (Optional)
    # Task.objects.all().delete() 

    tasks_to_create = [
        # SECTION: Estrutura & Salão
        {"title": "Ligar a água (fica do lado de fora e desligada)", "section": "Estrutura", "responsible": "Geral"},
        {"title": "Lavar o salão", "section": "Salão", "responsible": "Geral"},
        {"title": "Lavar cadeiras", "section": "Salão", "responsible": "Geral"},
        {"title": "Manter os 2 filtros cheios", "section": "Estrutura", "responsible": "Geral"},
        {"title": "Trocar sacos das lixeiras", "section": "Estrutura", "responsible": "Geral"},
        
        # SECTION: Banheiros
        {"title": "Lavar os banheiros (interno e consulentes)", "section": "Banheiros", "responsible": "Geral"},
        {"title": "Verificar os papéis higiênicos e repor", "section": "Banheiros", "responsible": "Geral"},

        # SECTION: Almas & Tronqueira
        {"title": "Manter mármore da casa das almas sem poeira", "section": "Almas/Tronqueira", "responsible": "Indiara/Iago/Bruno"},
        {"title": "Manter limpos e trocar Tronqueira madeira/elementos", "section": "Almas/Tronqueira", "responsible": "Indiara/Iago/Bruno"},
        {"title": "Observar estado e limpar os elementos pra troca: charutos e cigarrilha, curiadores", "section": "Almas/Tronqueira", "responsible": "Indiara/Iago/Bruno"},
        {"title": "Observar se os barros estão embolorados e lavar devidamente com sabão e bucha (preferência deixar uma bucha e pano separados apenas para isso)", "section": "Almas/Tronqueira", "responsible": "Indiara/Iago/Bruno"},

        # SECTION: Congá
        {"title": "Manter mesa do congá limpa e aparadores laterais", "section": "Congá", "responsible": "Marina/Angelo/Elaine"},
        {"title": "Limpar taças de congá e trocar a água", "section": "Congá", "responsible": "Marina/Angelo/Elaine"},
        {"title": "Limpar porta velas", "section": "Congá", "responsible": "Marina/Angelo/Elaine"},

        # SECTION: Inventário & Organização
        {"title": "Manter almoxarifado organizado", "section": "Inventário", "responsible": "Geral"},
        {"title": "Observar o que está sem sinalizar (e sinalizar com etiquetas)", "section": "Inventário", "responsible": "Geral"},
        {"title": "Observar materiais e bebidas que faltam e sinalizar", "section": "Inventário", "responsible": "Geral"},
        {"title": "Manter barros, alguidares, taças, portas velas limpos e guardados nos seus devidos lugares", "section": "Organização", "responsible": "Geral"},
        {"title": "Não deixar resto de lixo nos potes ou em lixo astral", "section": "Organização", "responsible": "Geral"},
    ]
    for task_data in tasks_to_create:
        Task.objects.get_or_create(
            title=task_data["title"],
            defaults={
                "section": task_data["section"],
                "responsible": task_data["responsible"],
                "completed": False
            }
        )
        print(f"Added: {task_data['title']}")

    print("--- Seeding finished successfully! ---")

if __name__ == '__main__':
    seed_tasks()