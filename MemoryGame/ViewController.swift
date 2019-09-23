//
//  ViewController.swift
//  MemoryGame
//
//  Created by Frances ZiyiFan on 9/21/19.
//  Copyright © 2019 Ray Kang. All rights reserved.
//

import UIKit
import Foundation

struct Image: Codable{
    let src: String
}

struct Products: Codable{
    let id: Int
    let image: Image
}

struct Card: Codable{
    let products: [Products]
}


class ViewController: UIViewController {
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var configLabel: UILabel!
    @IBOutlet weak var gridOption1Label: UILabel!
    @IBOutlet weak var gridOption2Label: UILabel!
    @IBOutlet weak var matchOption1Label: UILabel!
    @IBOutlet weak var matchOptionLabel2: UILabel!
    @IBOutlet weak var configSwitch1: UISwitch!
    @IBOutlet weak var configSwitch2: UISwitch!
    @IBOutlet weak var configView: UIView!
    
    var cards: [UIImageView] = []
    let urlString = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    var cardsArray: [Products] = []
    var board: [Products] = []
    var selected1: Products!
    var selected1Index = 0
    var selected2: Products!
    var selected2Index = 0
    var selected3: Products!
    var numMatched = 0
    var cardWidth : CGFloat!
    var cardHeight : CGFloat!
    var gridColumn : Int!
    var gridRow : Int!
    var matchPair : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func configureGameSetting(_ sender: Any) {
        if configSwitch1.isOn && !configSwitch2.isOn{
            self.gridRow = 6
            self.gridColumn = 5
            self.matchPair = 2
            startPlay()
        }else if !configSwitch1.isOn && !configSwitch2.isOn{
            self.gridRow = 4
            self.gridColumn = 5
            self.matchPair = 2
            startPlay()
        }else if configSwitch1.isOn && configSwitch2.isOn{
            self.gridRow = 6
            self.gridColumn = 5
            self.matchPair = 3
            startPlay()
        }else{
            let alertController = UIAlertController(title: "Bad Grid Option", message: "Please choose a different grid configuration", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private func startPlay(){
        let numOfCards = self.gridColumn*self.gridRow
        self.configView.alpha = 0
        self.view.bringSubviewToFront(scoreLabel)
        self.view.bringSubviewToFront(descriptionLabel)
        scoreLabel.text = "0"
        configGrid(numOfCards: numOfCards)
        fetchCards()
    }
    
    private func restart(){
        self.configView.alpha = 1
        self.view.bringSubviewToFront(configView)
        scoreLabel.text = "0"
        numMatched = 0
    }
    
    private func configGrid(numOfCards: Int){
        self.cardWidth = ((self.view.frame.width - (10*6))/5)
        self.cardHeight = (self.view.frame.height - 100)
        for i in 0..<numOfCards {
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGestureRecog:)))
            let card = UIImageView()
            card.image = UIImage(named: "cardback")
            card.translatesAutoresizingMaskIntoConstraints = false
            card.isUserInteractionEnabled = true
            card.addGestureRecognizer(tapRecog)
            self.cards.append(card)
        }
        setUpGrid(column: self.gridColumn, row: self.gridRow)
    }
    
    private func setUpGrid(column: Int, row: Int){
        var cardIndex = 0
        for r in 0..<row {
            for c in 0..<column{
                self.view.addSubview(cards[cardIndex])
                cards[cardIndex].restorationIdentifier = "\(cardIndex)"
                NSLayoutConstraint.activate([
                    cards[cardIndex].topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(100+(r*(90+10)))),
                    cards[cardIndex].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: CGFloat(15+(c*(70+10)))),
                    cards[cardIndex].widthAnchor.constraint(equalToConstant: self.cardWidth),
                    cards[cardIndex].heightAnchor.constraint(equalToConstant: 90)
                ])
                cardIndex += 1
            }
        }
    }
    
    private func fetchCards(){
        let url = URL(string: self.urlString)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, err) in
            guard err == nil else{
                print("can't access json: \(String(describing: err))")
                return
            }
            guard let data = data else {
                print("bad data")
                return
            }
            let cards = try? JSONDecoder().decode(Card.self, from: data)
            self.cardsArray = cards!.products
            self.setUpBoard()
        }
        task.resume()
    }
    
    private func setUpBoard(){
        if(!self.board.isEmpty){
            self.board.removeAll()
        }
        var indexArray = [Int]()
        var i = 0
        while board.count < self.gridColumn*self.gridRow {
            while true {
                var repeated = false
                i = Int(arc4random_uniform(49))
                
                for n in 0..<indexArray.count{
                    if(indexArray[n] == i){
                        repeated = true
                    }
                }
                
                if(!repeated){
                    indexArray.append(i)
                    break
                }
            }
            for t in 0..<self.matchPair{
                board.append(cardsArray[i])
            }
        }
        shuffle()
    }
    
    private func shuffle(){
        for i in 0...49{
            let shuffleIndex1 = Int(arc4random_uniform(19))
            let shuffleIndex2 = Int(arc4random_uniform(19))
            board.swapAt(shuffleIndex1, shuffleIndex2)
        }
    }
    
    @objc private func handleTap(tapGestureRecog: UITapGestureRecognizer){
        
        let tappedIndex = (tapGestureRecog.view?.restorationIdentifier as! NSString).integerValue
        let url = URL(string: board[tappedIndex].image.src)
        let data = try? Data(contentsOf: url!)
        self.cards[tappedIndex].image = UIImage(data: data!)
        self.view.setNeedsDisplay()
        
        switch matchPair {
        case 3:
            if(selected1==nil){
                selected1 = board[tappedIndex]
                selected1Index = tappedIndex
            }else if(selected2 == nil && tappedIndex != selected1Index){
                selected2 = board[tappedIndex]
                selected2Index = tappedIndex
            }else if(selected3 == nil && tappedIndex != selected1Index && tappedIndex != selected2Index){
                selected3 = board[tappedIndex]
                if(selected1.id == selected2.id && selected1.id == selected3.id){
                    self.numMatched += 1
                    UIView.animate(withDuration: 1, animations: {
                        self.cards[tappedIndex].alpha = 0
                        self.cards[self.selected1Index].alpha = 0
                        self.cards[self.selected2Index].alpha = 0
                    }, completion: nil)
                    self.scoreLabel.text = "\(numMatched)"
                    if(numMatched == board.count/3){
                        self.cards.removeAll()
                        let alertController = UIAlertController(title: "Hooray", message: "Congrats! You've won!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Play Again", style: .default, handler: {(_) in
                            self.restart()
                        }))
                        alertController.addAction(UIAlertAction(title: "Quit", style: .cancel, handler: {(_) in
                            exit(0)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }else{
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
                        self.cards[self.selected1Index].image = UIImage(named: "cardback")
                        self.cards[self.selected2Index].image = UIImage(named: "cardback")
                        self.cards[tappedIndex].image = UIImage(named: "cardback")
                    })
                }
                selected1 = nil
                selected2 = nil
                selected3 = nil
            }
            
            
        default:
        if(selected1==nil){
            selected1 = board[tappedIndex]
            selected1Index = tappedIndex
        }else if(selected1Index != tappedIndex){
            selected2 = board[tappedIndex]
            if(selected1.id == selected2.id){
                self.numMatched += 1
                cards[tappedIndex].isUserInteractionEnabled = false
                cards[selected1Index].isUserInteractionEnabled = false
                UIView.animate(withDuration: 1, animations: {
                    self.cards[tappedIndex].alpha = 0
                    self.cards[self.selected1Index].alpha = 0
                }, completion: nil)
                self.scoreLabel.text = "\(numMatched)"
                if(numMatched == board.count/2){
                    self.cards.removeAll()
                    let alertController = UIAlertController(title: "Hooray", message: "Congrats! You've won!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Play Again", style: .default, handler: {(_) in
                        self.restart()
                    }))
                    alertController.addAction(UIAlertAction(title: "Quit", style: .cancel, handler: {(_) in
                        exit(0)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }else{
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
                    self.cards[self.selected1Index].image = UIImage(named: "cardback")
                    self.cards[tappedIndex].image = UIImage(named: "cardback")
                })
            }
            selected1 = nil
            selected2 = nil
        }
    }
    
}


}

