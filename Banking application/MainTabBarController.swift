//
//  ViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dashboardVC = UINavigationController(rootViewController: DashboardViewController())
        dashboardVC.tabBarItem = UITabBarItem(title: "Главная страница", image: UIImage(systemName: CustomImagesAssets.house), tag: 0)
        
        let mapVC = UINavigationController(rootViewController: MapViewController())
        mapVC.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(systemName: CustomImagesAssets.map), tag: 1)
        
        let ratesVC = UINavigationController(rootViewController: ExchangeRatesViewController())
        ratesVC.tabBarItem = UITabBarItem(title: "Курсы", image: UIImage(systemName: CustomImagesAssets.dollarsignCircle), tag: 2)
        
        let converterVC = UINavigationController(rootViewController: ConverterViewController())
        converterVC.tabBarItem = UITabBarItem(title: "Конвертер", image: UIImage(systemName: CustomImagesAssets.arrowLeftArrowRight), tag: 3)
        
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: CustomImagesAssets.gear), tag: 4)
        
        viewControllers = [dashboardVC, mapVC, ratesVC, converterVC, settingsVC]
    }
}

struct CustomImagesAssets {
    static let house = "house"
    static let map = "map"
    static let dollarsignCircle = "dollarsign.circle"
    static let arrowLeftArrowRight = "arrow.left.arrow.right"
    static let gear = "gear"
}
