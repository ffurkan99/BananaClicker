import os
from PIL import Image

def make_flood_fill_transparent(img_path, target_color, tolerance=30):
    if not os.path.exists(img_path):
        print(f"File not found: {img_path}")
        return False
    
    im = Image.open(img_path)
    im = im.convert("RGBA")
    width, height = im.size
    data = im.load()
    
    visited = [[False for _ in range(height)] for _ in range(width)]
    
    # Initialize queue with all border pixels to ensure we flood fill all outer background areas
    queue = []
    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
        visited[x][0] = True
        visited[x][height - 1] = True
        
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))
        visited[0][y] = True
        visited[width - 1][y] = True
        
    def color_match(c1, c2):
        return (abs(c1[0] - c2[0]) <= tolerance and
                abs(c1[1] - c2[1]) <= tolerance and
                abs(c1[2] - c2[2]) <= tolerance)
                
    while queue:
        x, y = queue.pop(0)
        curr_pixel = data[x, y]
        
        # If it matches the target background color and is opaque or semi-opaque
        if color_match(curr_pixel, target_color) and curr_pixel[3] > 0:
            # Set to fully transparent
            data[x, y] = (0, 0, 0, 0)
            
            # Check 4-neighbors
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < width and 0 <= ny < height and not visited[nx][ny]:
                    visited[nx][ny] = True
                    queue.append((nx, ny))
                    
    im.save(img_path, "PNG")
    print(f"Cleaned background for: {img_path}")
    return True

# Colors to remove
gray_background = (130, 130, 130)
white_background = (255, 255, 255)

assets_to_clean = {
    "assets/images/pixel_monkey.png": gray_background,
    "assets/images/pixel_banana.png": white_background,
    "assets/images/upgrade_banana_boost.png": white_background,
    "assets/images/upgrade_jungle_basket.png": white_background,
}

for path, color in assets_to_clean.items():
    make_flood_fill_transparent(path, color)
