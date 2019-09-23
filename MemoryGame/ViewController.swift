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

    var cards: [UIImageView] = []
    let urlString = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    var cardsArray: [Products] = []
    var board: [Products] = []
    var selected1: Products!
    var selected1Index = 0
    var selected2: Products!
    var numMatched = 0
    var cardWidth : CGFloat!
    var cardHeight : CGFloat!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(scoreLabel)
        self.view.bringSubviewToFront(descriptionLabel)
        scoreLabel.text = "0"
        configGrid(numOfCards: 30)
        fetchCards()
    }
    
    private func restart(){
        scoreLabel.text = "0"
        numMatched = 0
        for i in 0..<cards.count{
            cards[i].image = UIImage(named: "cardback")
            cards[i].alpha = 1
            cards[i].isUserInteractionEnabled = true
        }
        setUpBoard()
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
        for index in 0..<(cards.count/2){
            let i = Int(arc4random_uniform(49))
            board.append(cardsArray[i])
            board.append(cardsArray[i])
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
                    let alertController = UIAlertController(title: "Hooray", message: "Congrats! You've won!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Play Again", style: .default, handler: {(_) in
                        print("Play again")
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
    
    
    //bonus features
    private func configGrid(numOfCards: Int){
        let row = numOfCards/5
        self.cardWidth = ((self.view.frame.width - (10*6))/5)
//        self.cardHeight = (self.view.frame.height - 100)
        for i in 0..<numOfCards {
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGestureRecog:)))
            let card = UIImageView()
            card.image = UIImage(named: "cardback")
            card.translatesAutoresizingMaskIntoConstraints = false
            card.isUserInteractionEnabled = true
            card.addGestureRecognizer(tapRecog)
            self.cards.append(card)
        }
        setUpGrid(column: 5, row: row)
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
    
    private func configMatch(pairs: Int){
        
    }

}

