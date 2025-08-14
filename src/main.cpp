#ifdef __APPLE__
#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#include <SFML/Main.hpp>
#endif
#endif

#include <SFML/Graphics.hpp>
#include <chrono>

int main()
{
    sf::ContextSettings settings{ .antiAliasingLevel = 16 };
    sf::RenderWindow window(sf::VideoMode({390, 844}), "SFML works!", sf::Style::Default, sf::State::Windowed, settings);
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    sf::Font font("assets/font.ttf");
    sf::Text text(font, "test  :)");

    text.setPosition(shape.getGlobalBounds().getCenter());

    auto speed = 5.f;
    auto start = std::chrono::steady_clock::now();
    while (window.isOpen())
    {
        auto now = std::chrono::steady_clock::now();
        std::chrono::duration<float> delta = now - start;
        start = now;

        while (const std::optional event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>())
            {
                window.close();
            }
        }

        text.rotate(sf::radians(speed) * delta.count());

        window.clear();
        window.draw(shape);
        window.draw(text);
        window.display();
    }
}
