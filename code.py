import time
import board
import wifi
import socketpool
import terminalio
import displayio
import adafruit_requests as requests
from adafruit_matrixportal.matrixportal import MatrixPortal
from adafruit_matrixportal.matrix import Matrix
from adafruit_display_text import label
import adafruit_display_text

# Initialize MatrixPortal
matrixportal = MatrixPortal(status_neopixel=board.NEOPIXEL, debug=True)

# Wi-Fi settings and connection
wifi.radio.connect('Tsar01-24', 'Chatham1')
print(f"Connected to wifi")
print(f"My IP address is {wifi.radio.ipv4_address}")

# Initialize the socket and requests
pool = socketpool.SocketPool(wifi.radio)
requests = requests.Session(pool)
matrix = Matrix()
display = matrix.display
g = displayio.Group()

# Static text area
text_area = label.Label(terminalio.FONT, text="", color=0xC60003)
g.append(text_area)

# Scrolling text area
scroll_text_area = label.Label(terminalio.FONT, text="Waiting for data...", color=0xC60003)
scroll_text_area.x = display.width
scroll_text_area.y = display.height - 10
g.append(scroll_text_area)

# Set the group on the display
display.show(g)

# Timing for API updates
last_update_time = time.monotonic()
update_interval = 10  # Update every 10 seconds
API_URL ="http://pioxy.net/api"


def scroll(line):
    line.x = line.x - 1
    line_width = line.bounding_box[2]
    if line.x < -line_width:
        line.x = display.width

def format_number_with_commas(number_str):
    formatted_number = ""
    for i in range(len(number_str)-1, -1, -1):
        formatted_number = number_str[i] + formatted_number
        if (len(number_str)-i) % 3 == 0 and i != 0:
            formatted_number = "," + formatted_number
    return formatted_number

# Main loop
while True:
    current_time = time.monotonic()

    # Update data every 10 seconds
    if current_time - last_update_time > update_interval:
        # Fetch data from API
        response = requests.get(API_URL)
        print(response)
        data = response.json()

        # Update static text area
        message = str(data["count"][0]["value"])
        formatted_message = format_number_with_commas(message)
        text_area.text = formatted_message
        text_width = text_area.bounding_box[2]
        text_area.x = (display.width - text_width) // 2
        text_area.y = (display.height - text_area.bounding_box[3]) // 2

        # Update scrolling text area
        scrolling_data = str(data["reason"][0]["reason"])  # Adjust field name as needed
        scroll_text_area.text = scrolling_data
        scroll_text_area.x = display.width  # Reset position for scrolling

        # Update last update time
        last_update_time = current_time

    # Scroll the text continuously
    scroll(scroll_text_area)

    # Short delay for smooth scrolling
    time.sleep(0.05)  # Adjust for desired scrolling speed
