#!/bin/bash

# URLs de imágenes para verificar
urls=(
    "https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1544124499-58912cbddaad?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1551248429-40975aa4de74?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1587740908075-1f6664b0ca8e?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1470324161839-ce2bb6fa6bc3?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1546173159-315724a31696?w=400&h=300&fit=crop&crop=center"
    "https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=400&h=300&fit=crop&crop=center"
)

echo "🔍 Verificando URLs de imágenes..."
echo "=================================="

broken_urls=()
working_urls=()

for url in "${urls[@]}"; do
    echo -n "Verificando: $(echo "$url" | sed 's/.*photo-\([^?]*\).*/\1/')... "
    
    response=$(curl -s -I "$url" | head -n 1)
    status_code=$(echo "$response" | grep -o '[0-9]\{3\}')
    
    if [[ "$status_code" == "200" ]]; then
        echo "✅ OK"
        working_urls+=("$url")
    else
        echo "❌ Error ($status_code)"
        broken_urls+=("$url")
    fi
done

echo ""
echo "📊 Resumen:"
echo "URLs funcionando: ${#working_urls[@]}"
echo "URLs rotas: ${#broken_urls[@]}"

if [ ${#broken_urls[@]} -gt 0 ]; then
    echo ""
    echo "❌ URLs que necesitan reemplazo:"
    for url in "${broken_urls[@]}"; do
        echo "  - $url"
    done
fi
