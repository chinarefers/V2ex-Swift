//
//  FavoritesViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/30/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    var topicList:Array<TopicListModel>?
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的收藏"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.showLoadingView()
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.tableView.mj_header.beginRefreshing()
    }
    
    func refresh(){
        //根据 tab name 获取帖子列表
        TopicListModel.getFavoriteList{
            [weak self](response:V2ValueResponse<[TopicListModel]>) -> Void in
            if response.success {
                if let weakSelf = self {
                    weakSelf.topicList = response.value
                    weakSelf.tableView.reloadData()
                }
            }
            self?.tableView.mj_header.endRefreshing()
            
            self?.hideLoadingView()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.topicList {
            return list.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = self.topicList![indexPath.row]
        let titleHeight = item.topicTitleLayout?.textBoundingRect.size.height ?? 0
        //          上间隔   头像高度  头像下间隔       标题高度    标题下间隔 cell间隔
        let height = 12    +  35     +  12      + titleHeight   + 12      + 8
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.topicList![indexPath.row]);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.topicList![indexPath.row]
        
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
    }
}
