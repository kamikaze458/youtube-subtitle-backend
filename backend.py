from flask import Flask, request, jsonify
from youtube_transcript_api import YouTubeTranscriptApi
import os
import openai

app = Flask(__name__)

# Configura la clave de OpenAI desde una variable de entorno
openai.api_key = os.getenv("OPENAI_API_KEY")

@app.route('/get_subtitles', methods=['POST'])
def get_subtitles():
    data = request.get_json()
    video_url = data.get('video_url')
    video_id = video_url.split("v=")[-1]  # Extrae el ID del video desde el URL
    
    try:
        # Obtiene los subtítulos en español o inglés
        transcript = YouTubeTranscriptApi.get_transcript(video_id, languages=['es', 'en'])
        subtitles = " ".join([item['text'] for item in transcript])

        # Llama a OpenAI para resumir los subtítulos
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "user", "content": f"Resumen de los subtítulos:\n\n{subtitles}"}
            ],
            temperature=0.5,
        )
        summary = response['choices'][0]['message']['content']
        return jsonify({'summary': summary})

    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
