from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Sample in-memory "database"
items = []

# Endpoint to add an item
@app.route('/add_item', methods=['POST'])
def add_item():
    data = request.json
    item_id = len(items) + 1
    new_item = {
        'id': item_id,
        'name': data.get('name'),
        'description': data.get('description')
    }
    items.append(new_item)
    return jsonify(new_item), 201

# Endpoint to get all items
@app.route('/get_items', methods=['GET'])
def get_items():
    return jsonify(items), 200

# Endpoint to delete an item
@app.route('/delete_item/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    global items
    items = [item for item in items if item['id'] != item_id]
    return jsonify({'message': 'Item deleted'}), 200

# Endpoint to update an item
@app.route('/update_item/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    data = request.json
    for item in items:
        if item['id'] == item_id:
            item['name'] = data.get('name', item['name'])
            item['description'] = data.get('description', item['description'])
            return jsonify(item), 200
    return jsonify({'message': 'Item not found'}), 404

if __name__ == '__main__':
    app.run(debug=True)
