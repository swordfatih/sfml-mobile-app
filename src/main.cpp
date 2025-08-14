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
    sf::RenderWindow window(sf::VideoMode({200, 200}), "SFML works!");
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    sf::Font font("assets/play.ttf");
    sf::Text text(font, "nadia :)");

    auto size = window.getSize();
    text.setPosition(sf::Vector2f{size.x / 2.f, size.y / 2.f});

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
