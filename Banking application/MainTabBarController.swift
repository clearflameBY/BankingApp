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
        
        // Services
        let currencyService = CurrencyService()
        let calculateService = CalculateService()
        let mapService = InformationForMapService()
        
        // Dashboard
        let dashboardRoot = DashboardViewController(service: currencyService, calculateService: calculateService)
        let dashboardVC = UINavigationController(rootViewController: dashboardRoot)
        dashboardVC.tabBarItem = UITabBarItem(title: "Главная страница", image: UIImage(systemName: CustomImagesAssets.house), tag: 0)
        
        // Map
        let mapRoot = MapViewController(service: mapService)
        let mapVC = UINavigationController(rootViewController: mapRoot)
        mapVC.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(systemName: CustomImagesAssets.map), tag: 1)
        
        // Rates
        let ratesRoot = ExchangeRatesViewController(service: currencyService)
        let ratesVC = UINavigationController(rootViewController: ratesRoot)
        ratesVC.tabBarItem = UITabBarItem(title: "Курсы", image: UIImage(systemName: CustomImagesAssets.dollarsignCircle), tag: 2)
        
        // Converter
        let converterRoot = ConverterViewController(service: currencyService, calculateService: calculateService)
        let converterVC = UINavigationController(rootViewController: converterRoot)
        converterVC.tabBarItem = UITabBarItem(title: "Конвертер", image: UIImage(systemName: CustomImagesAssets.arrowLeftArrowRight), tag: 3)
        
        // Settings
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
