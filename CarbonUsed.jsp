<%@ page pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>煤用量</title>
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/themes/gray/easyui.css" />
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/themes/icon.css" />
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/main.css" />
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/formstyle.css" />
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/showLoading.css" />
		<link rel="stylesheet" type="text/css" href="${ctxp}/resources/css/Styles/demo.css">

		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.min.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.easyui.min.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//easyui-lang-zh_CN.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.showLoading.min.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.flot.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.leanModal.min.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//cookie.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//DataGrid.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.flot.time.js"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//jquery.flot.categories.js"></script>
		<script src="../../../resources/jquery/common.js" type="text/javascript" charset="utf-8"></script>
		<script type="text/javascript" src="${ctxp}/resources/jquery//tree.js"></script>
		<script src="../../../resources/jquery/storage.js" type="text/javascript" charset="utf-8"></script>
		<script type="text/javascript">
			$(document).ready(function() {
				initConf();
				TreeHelper.showTree(false, '用电单位');
				$('#datagridDiv').height($('#layout-center').height() - $('#content').outerHeight());
				initTable();
			});

			function initTable() {
				DataGird.LoadUrlData('dataGridList', '/pcm/carbonused!findByUnit.do', {
					unitNo: TreeHelper.TreeNode.id
				}, true, true, 20);
			}

			function reLoad() {
				DataGird.reload('dataGridList', {
					unitNo: TreeHelper.TreeNode.id
				});
			}

			function onLeafSelect(node) {
				reLoad();
			}

			function add() {
				$('#editForm').form('clear');
				$('#unitid').textbox('setValue', TreeHelper.TreeNode.id);
				$('#rateInput').numberbox('setValue', _conf.rate);
				$('.easyui-datebox').datebox('setValue', "true");
				$('#editDialog').dialog('open').dialog('setTitle', '信息录入');
			}

			function edit() {
				var row = $('#dataGridList').datagrid('getSelected');
				if(row) {
					$('#editForm').form('clear');
					$('#editForm').form('load', row);
					$('#editDialog').dialog('open').dialog('setTitle', '修改记录');
				} else {
					Messager.show('操作提示', '请选择需要修改的记录!');
				}
			}

			function del() {
				var row = $('#dataGridList').datagrid('getSelected');
				if(row) {
					Messager.confirm('操作提示', '确定删除该条记录？', function(success) {
						if(success) {
							$.post('/pcm/carbonused!delete.do', {
								'id': row["id"]
							}, function(result) {
								if(result.success) {
									reLoad();
								} else {
									$.messager.alert('操作提示', "删除失败：" + result.msg);
								}
							});
						}
					});
				} else {
					Messager.show('操作提示', '请选择需要删除的记录!');
				}

			}

			function submitForm() {
				var isValid = $('#editForm').form('validate');
				if(!isValid) {
					Messager.show('操作提示', '请完整填写信息!');
					return;
				}
				_conf.rate = $('#rateInput').numberbox('getValue');
				saveConf();
				$.ajax({
					type: "POST",
					url: '/pcm/carbonused!save.do',
					data: $('#editForm').serialize(),
					success: function(result) {
						if(result.success) {
							reLoad();
							$('#editDialog').dialog('close')
							Messager.show('操作提示', '保存成功!');
						} else {
							Messager.show('操作提示', '保存失败!');
						}
					}
				});
			}

			function setLimitAlarm() {
				$('#alarmEditForm').form('clear');
				$('#alarmEditTitle').text('企业/单位：' + TreeHelper.TreeNode.text);
				$.ajax({
					type: "post",
					url: "/pcm/carbonused!getLimitAlarm.do",
					data: {
						no: TreeHelper.TreeNode.id
					},
					async: false,
					success: function(result) {
						if(result.success) {
							$('#alarmEditForm').form('load', result.data);
						} else {
							$('#alarmUnitNo').textbox('setValue', TreeHelper.TreeNode.id);
						}
					}
				});
				$('#alarmDialog').dialog('open').dialog('setTitle', '越限告警设置');
			}

			function saveLimitAlarm() {
				var isValid = $('#alarmEditForm').form('validate');
				if(!isValid) {
					Messager.show('操作提示', '请完整填写信息!');
					return;
				}
				$.ajax({
					type: "POST",
					url: '/pcm/carbonused!saveLimitAlarm.do',
					data: $('#alarmEditForm').serialize(),
					success: function(result) {
						if(result.success) {
							$('#alarmDialog').dialog('close')
							Messager.show('操作提示', '保存成功!');
						} else {
							Messager.show('操作提示', '保存失败!');
						}
					}
				});
			}

			function setCoefficient() {
				$('#coeffEditForm').form('clear');
				$('#coeffEditForm').form('load', {
					waterCoeff: Storage.local['waterCoeff'],
					powerCoeff: Storage.local['powerCoeff'],
					gasCoeff: Storage.local['gasCoeff']
				});
				$('#coeffDialog').dialog('open').dialog('setTitle', '设置');
			}

			function saveCoefficient() {
				var isValid = $('#coeffEditForm').form('validate');
				if(!isValid) {
					Messager.show('操作提示', '请完整填写信息!');
					return;
				}
				try {
					var coeff = serializeToObject($('#coeffEditForm').serialize());
					Storage.local['waterCoeff'] = coeff.waterCoeff;
					Storage.local['powerCoeff'] = coeff.powerCoeff;
					Storage.local['gasCoeff'] = coeff.gasCoeff;
					$('#coeffDialog').dialog('close')
					Messager.show('操作提示', '保存成功!');
				} catch(e) {
					Messager.show('操作提示', '保存失败!');
				}

			}
		</script>
	</head>

	<body>
		<div class="easyui-layout" data-options="fit:true">
			<div data-options="region:'west',split:true" style="width: 250px;" title="企业/单位">
				<ul id="tree"></ul>
			</div>
			<div data-options="region:'center'" id="layout-center" style="overflow: hidden;">
				<div id="content">
					<div class="inputdiv">
						<div class="divControl">
							<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add'" onclick="add()">信息录入</a>&nbsp;&nbsp;
							<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-edit'" onclick="edit()">修改记录</a>&nbsp;&nbsp;
							<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-remove'" onclick="del()">删除记录</a>&nbsp;&nbsp;
							<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-record'" onclick="setLimitAlarm()">越限告警</a>&nbsp;&nbsp;
							<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-change'" onclick="setCoefficient()">折标系数</a>&nbsp;&nbsp;
						</div>
					</div>
				</div>
				<div id="datagridDiv" style="width: 100%;">
					<table id="dataGridList" class="easyui-datagrid" style="height: 100%;">
						<thead>
							<tr>
								<th data-options="field:'id',align:'left',hidden:true,width:10"></th>
								<th data-options="field:'unitid',align:'left',hidden:true,width:10"></th>
								<th data-options="field:'time',align:'left',hidden:true,width:10"></th>
								<th data-options="field:'dateStr',align:'left',width:10">日期时间</th>
								<th data-options="field:'dosage' ,align:'left' ,width:10">煤用量(吨)</th>
								<th data-options="field:'rate' ,align:'left',width:10">费率(元/吨)</th>
								<th data-options="field:'amount',align:'left',width:10">费用(元)</th>
							</tr>
						</thead>
					</table>
				</div>

				<div id="editDialog" class="easyui-dialog" style="width: auto; height: auto; padding: 10px 20px" closed="true" buttons="#editDialog-buttons">
					<form class="form" id="editForm" name="changePWForm" method="post" action="">
						<div style="display: none">
							<input name="id" class="easyui-textbox">
							<input id="unitid" name="unitid" class="easyui-textbox">
						</div>
						<table style="width: 300px;border-collapse:separate; border-spacing:10px;">
							<tr>
								<td>日期时间</td>
								<td>
									<input class="easyui-datebox" name="time" editable="false" data-options="required:true,showSeconds:false" style="width: 150px;">
								</td>
							</tr>
							<tr>
								<td>煤用量(吨)</td>
								<td>
									<input class="easyui-numberbox" type="text" name="dosage" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;">
								</td>
							</tr>
							<tr>
								<td>费率(元/吨)</td>
								<td><input id="rateInput" class="easyui-numberbox" type="text" name="rate" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
						</table>
					</form>
				</div>
				<div id="editDialog-buttons">
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-ok" onclick="submitForm()" style="width: 90px">确定</a>
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-cancel" onclick="$('#editDialog').dialog('close')" style="width: 90px"> 取消 </a>
				</div>

				<div id="alarmDialog" class="easyui-dialog" style="width: auto; height: auto; padding: 10px 20px" closed="true" buttons="#alarmDialog-buttons">
					<form class="form" id="alarmEditForm" method="post" action="">
						<div class="ftitle" id="alarmEditTitle">企业/单位</div>
						<div style="display: none">
							<input name="pkid" class="easyui-textbox">
							<input id="alarmUnitNo" name="unitno" class="easyui-textbox">
						</div>
						<table style="width: 300px;border-collapse:separate; border-spacing:10px;">
							<tr>
								<td>预警值(吨)</td>
								<td><input class="easyui-numberbox" type="text" name="earlywarnvalue" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
							<tr>
								<td>告警值(吨)</td>
								<td><input class="easyui-numberbox" type="text" name="alarmvalue" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
						</table>
					</form>
				</div>
				<div id="alarmDialog-buttons">
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-ok" onclick="saveLimitAlarm()" style="width: 90px">确定</a>
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-cancel" onclick="$('#alarmDialog').dialog('close')" style="width: 90px"> 取消 </a>
				</div>

				<div id="coeffDialog" class="easyui-dialog" style="width: auto; height: auto; padding: 10px 20px" closed="true" buttons="#coeffDialog-buttons">
					<form class="form" id="coeffEditForm" method="post" action="">
						<div class="ftitle" id="coeffEditTitle">折标系数</div>
						<div style="display: none">
							<input name="pkid" class="easyui-textbox">
						</div>
						<table style="width: 300px;border-collapse:separate; border-spacing:10px;">
							<tr>
								<td>水折标系数</td>
								<td><input class="easyui-numberbox" type="text" name="waterCoeff" id="waterCoeff" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
							<tr>
								<td>电折标系数</td>
								<td><input class="easyui-numberbox" type="text" name="powerCoeff" id="powerCoeff" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
							<tr>
								<td>气折标系数</td>
								<td><input class="easyui-numberbox" type="text" name="gasCoeff" id="gasCoeff" value="0" data-options="required:true,min:0,precision:1" style="width: 150px;"></td>
							</tr>
						</table>
					</form>
				</div>
				<div id="coeffDialog-buttons">
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-ok" onclick="saveCoefficient()" style="width: 90px">确定</a>
					<a href="javascript:void(0)" class="easyui-linkbutton" iconcls="icon-cancel" onclick="$('#coeffDialog').dialog('close')" style="width: 90px"> 取消 </a>
				</div>
			</div>
		</div>
	</body>

</html>