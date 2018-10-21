//
//  ContainersViewController.swift
//  ExampleApp
//
//  Created by Taras Nikulin on 21.10.2018.
//  Copyright © 2018 FlowKit. All rights reserved.
//

import UIKit

class ContainersViewController: UIViewController {

    @IBOutlet public var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.director.register(adapter: ContainerCellAdapter())
        self.tableView?.director.add(section: self.getSection())

        self.tableView?.director.rowHeight = .autoLayout(estimated: 100)
        self.tableView?.director.reloadData(after: { _ in
            return TableReloadAnimations.default()
        }, onEnd: nil)

    }

    func getSection() -> TableSection {
        var models: [ContainerCellModel] = []
        for i in 0..<70 {
            let view = UILabel()
            let numberOfLines = i % 2
            print(numberOfLines)
            view.numberOfLines = numberOfLines
            if numberOfLines == 0 {
                view.text = "This\nis\nmultiline\nlabel"
            } else {
                view.text = "This is one line label. This is one line label. This is one line label. This is one line label."
            }
            let model = ContainerCellModel(view: view)
            models.append(model)
        }

        return TableSection(models)
    }
}
