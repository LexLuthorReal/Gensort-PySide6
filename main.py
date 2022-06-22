import os
import re
import sys
import pathlib
import filetype
import argparse
from PIL import Image
from typing import List, Union, Any
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtCore import QObject, Slot, QAbstractListModel, Property, QUrl, Qt

MINIMAL_CATEGORIES_COUNT = 10
WORK_FOLDER = pathlib.Path(__file__).parent.resolve()


def sorted_nicely(original: List) -> List:
    if len(original) != 0:
        def convert(text): return int(text) if text.isdigit() else text
        def numeric_sort(key): return [convert(c) for c in re.split('([0-9]+)', key)]
        original.sort(key=numeric_sort)
        return original
    return original


def create_folder_path(target_path: Union[os.PathLike, str]) -> Union[os.PathLike, str]:
    import pathlib
    pathlib.Path(target_path).mkdir(parents=True, exist_ok=True)
    return target_path


def photo_resolution(photo_path: str) -> str:
    width, height = Image.open(photo_path).size
    return str(width) + "x" + str(height)


def convert_bytes(size: int, unit: str) -> str:
    if unit == "KB":
        return str(round(size / 1024, 2)) + unit
    elif unit == "MB":
        return str(round(size / (1024 * 1024), 2)) + unit
    elif unit == "GB":
        return str(round(size / (1024 * 1024 * 1024), 2)) + unit
    else:
        return str(size) + 'B'


class Gensort(QObject):

    def __init__(self, app, categories_count: int, parent=None):
        super().__init__(parent=parent)
        self.app = app
        self.count = categories_count
        self.mime_formats = ["image/jpeg", "image/png"]

    def get_data_from_list_model(self, model: QAbstractListModel) -> List:
        """
        Documentation:
        1. https://doc.qt.io/qtforpython-5/PySide2/QtCore/QAbstractItemModel.html
        2. https://doc.qt.io/qtforpython-5/PySide2/QtCore/QAbstractListModel.html

        :param model: ListModel from QML
        :return: list with all elements
        """

        data = []
        headers = {v.data().decode(): k for k, v in model.roleNames().items()}

        for i in range(model.rowCount()):
            row = dict()
            item = model.index(i, 0)
            item_data = model.itemData(item)
            for name, role in headers.items():
                row[name] = item_data[role]

            data.append(row)

        for element in data:
            for key, value in element.items():
                if isinstance(value, str):
                    if value.isnumeric():
                        element[key] = int(value)
                if isinstance(value, float):
                    element[key] = int(value)
                if isinstance(value, QAbstractListModel):
                    element[key] = self.get_data_from_list_model(model=value)

        return data

    @Slot("QAbstractListModel*", QUrl, name="export_data", result=bool)
    def export_data(self, model: QAbstractListModel, save_folder: QUrl) -> bool:
        """
        Documentation:
        1. https://doc.qt.io/qtforpython-5/PySide2/QtCore/QAbstractItemModel.html
        2. https://doc.qt.io/qtforpython-5/PySide2/QtCore/QAbstractListModel.html

        :param model: ListModel from QML
        :param save_folder: export path
        :return: list with all elements
        """

        data = self.get_data_from_list_model(model=model)
        save_folder = save_folder.toLocalFile()

        for category in data:
            category_folder = os.path.join(save_folder, category["name"])
            create_folder_path(target_path=category_folder)

            for photo in category["photos"]:
                photo_path = QUrl(photo["photo_path"]).toLocalFile()
                original_filename = os.path.basename(photo_path)
                image = Image.open(fp=photo_path, mode="r")
                image = image.rotate(photo["rotation"])
                image.save(fp=os.path.join(category_folder, original_filename))

        return True

    @Slot(QUrl, bool, name="photos_from_folder", result=list)
    def photos_from_folder(self, current_folder: QUrl, include_subdir: bool) -> List[Union[List]]:
        current_folder = current_folder.toLocalFile()
        model_file_name, model_file_path, model_file_size, model_file_resolution = [], [], [], []

        current_folder_files = []

        if not include_subdir:

            for root, dirs, files in os.walk(current_folder):
                sorted_nicely(dirs)
                sorted_nicely(files)
                files = [f for f in files if not f[0] == '.']
                dirs[:] = [d for d in dirs if not d[0] == '.']
                current_folder_files.extend(files)
                break

            for filename in current_folder_files:
                file = os.path.join(current_folder, filename)
                try:
                    kind = filetype.guess(file)
                except BaseException:
                    kind = None
                if kind is not None:
                    if filetype.guess(file).mime in self.mime_formats:
                        model_file_name.append(os.path.basename(file))
                        model_file_path.append(QUrl.fromLocalFile(file))
                        model_file_size.append(convert_bytes(size=os.path.getsize(file), unit="KB"))
                        model_file_resolution.append(photo_resolution(photo_path=file))

        else:

            for root, dirs, files in os.walk(current_folder):
                sorted_nicely(dirs)
                sorted_nicely(files)
                files = [f for f in files if not f[0] == '.']
                dirs[:] = [d for d in dirs if not d[0] == '.']
                for filename in files:
                    file = os.path.join(root, filename)
                    try:
                        kind = filetype.guess(file)
                    except BaseException:
                        kind = None
                    if kind is not None:
                        if filetype.guess(file).mime in self.mime_formats:
                            model_file_name.append(os.path.basename(file))
                            model_file_path.append(QUrl.fromLocalFile(file))
                            model_file_size.append(convert_bytes(size=os.path.getsize(file), unit="KB"))
                            model_file_resolution.append(photo_resolution(photo_path=file))

        return [model_file_name, model_file_path, model_file_size, model_file_resolution]

    @Property(type=int, constant=True)
    def categories_count(self):
        return self.count


def load_env() -> None:
    from os import environ

    environ["QT_SCALE_FACTOR"] = "0.8"
    environ["QT_DEVICE_PIXEL_RATIO"] = "0"
    environ["QT_SCREEN_SCALE_FACTORS"] = "1"
    environ["QT_AUTO_SCREEN_SCALE_FACTOR"] = "1"
    environ["QT_QUICK_CONTROLS_STYLE"] = "Fusion"
    environ["QT_QUICK_CONTROLS_HOVER_ENABLED"] = "1"


def parse_args() -> dict[str, Any]:
    all_args = argparse.ArgumentParser()

    all_args.add_argument("-categories_count", "--categories_count", required=False,
                          help="Set categories count for sorting photos.")

    return vars(all_args.parse_args())


if __name__ == "__main__":
    """
    Documentation: https://doc.qt.io/qtforpython-5/modules.html
    Documentation: https://doc.qt.io/qtforpython-6/modules.html
    """
    # Init env
    load_env()
    args = parse_args()

    categories_count_arg = args["categories_count"]
    if categories_count_arg is None:
        categories_count_arg = MINIMAL_CATEGORIES_COUNT
    elif isinstance(categories_count_arg, str):
        categories_count_arg = int(categories_count_arg)

    # Create instance app
    application = QGuiApplication(sys.argv)
    # Set HiDPI
    application.setAttribute(Qt.ApplicationAttribute.AA_EnableHighDpiScaling)

    # Set Font
    my_font = QFont("Arial")
    application.setFont(my_font)

    # Create object UI
    photo_sorter = Gensort(app=application, categories_count=categories_count_arg)
    # Create QML Engine
    engine = QQmlApplicationEngine()
    # Register in context QML
    engine.rootContext().setContextProperty("Gensort", photo_sorter)
    # Load QML in engine
    engine.load(os.path.join(WORK_FOLDER, "qml", "App.qml"))
    # Connect Exit to Engine when app is close
    engine.quit.connect(application.quit)
    sys.exit(application.exec())
