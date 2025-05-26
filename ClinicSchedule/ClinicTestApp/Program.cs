using ClinicScheduleContracts.BindingModels;
using ClinicScheduleDatabaseImplement.Implements;
using ClinicScheduleModels.Enums;
using System;

var departmentStorage = new DepartmentStorage();
var doctorStorage = new DoctorStorage();
var nurseStorage = new NurseStorage();
var shiftStorage = new ShiftStorage();
var scheduleStorage = new ScheduleStorage();

var departments = new[]
{
    new DepartmentBindingModel { name = "Хирургия" },
    new DepartmentBindingModel { name = "Педиатрия" }
};

foreach (var dep in departments)
{
    if (departmentStorage.GetFilteredList(new() { name = dep.name }).Count == 0)
    {
        departmentStorage.Insert(dep);
        Console.WriteLine($"Добавлен департамент: {dep.name}");
    }
    else
    {
        Console.WriteLine($"Департамент {dep.name} уже существует");
    }
}

var departmentList = departmentStorage.GetFullList();

foreach (var dep in departmentList)
{
    for (int i = 1; i <= 2; i++)
    {
        var doctorFullname = $"Доктор {dep.name} #{i}";
        if (doctorStorage.GetFilteredList(new() { fullname = doctorFullname }).Count == 0)
        {
            doctorStorage.Insert(new DoctorBindingModel
            {
                login = $"doc{dep.id}_{i}",
                password = "pass",
                fullname = doctorFullname,
                birthdate = new DateTime(1980 + i, 1, 1),
                phoneNumber = "1234567890",
                specialization = "Терапия",
                experienceYears = 5 + i,
                departmentId = dep.id
            });
            Console.WriteLine($"Добавлен доктор: {doctorFullname}");
        }
        else
        {
            Console.WriteLine($"Доктор {doctorFullname} уже существует");
        }

        var nurseFullname = $"Медсестра {dep.name} #{i}";
        if (nurseStorage.GetFilteredList(new() { fullname = nurseFullname }).Count == 0)
        {
            nurseStorage.Insert(new NurseBindingModel
            {
                login = $"nurse{dep.id}_{i}",
                password = "pass",
                fullname = nurseFullname,
                birthdate = new DateTime(1990 + i, 1, 1),
                phoneNumber = "0987654321",
                specialization = "Общая практика",
                experienceYears = 3 + i,
                departmentId = dep.id
            });
            Console.WriteLine($"Добавлена медсестра: {nurseFullname}");
        }
        else
        {
            Console.WriteLine($"Медсестра {nurseFullname} уже существует");
        }
    }


    // Смены
    var today = DateTime.Today;
    var shifts = new[]
    {
        new ShiftBindingModel
        {
            startTime = today.AddHours(8),
            endTime = today.AddHours(14),
            requiredDoctors = 1,
            requiredNurses = 1,
            departmentId = dep.id
        },
        new ShiftBindingModel
        {
            startTime = today.AddHours(14),
            endTime = today.AddHours(20),
            requiredDoctors = 1,
            requiredNurses = 1,
            departmentId = dep.id
        }
    };

    foreach (var shift in shifts)
    {
        var existingShift = shiftStorage.GetFilteredList(new() { departmentId = dep.id })
            .FirstOrDefault(s => s.startTime == shift.startTime && s.endTime == shift.endTime);

        if (existingShift == null)
        {
            shiftStorage.Insert(shift);
            Console.WriteLine($"Добавлена смена: {shift.startTime:HH:mm} - {shift.endTime:HH:mm} для департамента {dep.name}");
        }
        else
        {
            Console.WriteLine($"Смена {shift.startTime:HH:mm}-{shift.endTime:HH:mm} уже существует для {dep.name}");
        }
    }

    // Расписание
    if (!scheduleStorage.GetFilteredList(new() { departmentId = dep.id, date = today }).Any())
    {
        var allShifts = shiftStorage.GetFilteredList(new() { departmentId = dep.id });
        var doctors = doctorStorage.GetFilteredList(new() { departmentId = dep.id });
        var nurses = nurseStorage.GetFilteredList(new() { departmentId = dep.id });

        var assignments = new List<ScheduleAssignmentBindingModel>();

        foreach (var shift in allShifts)
        {
            assignments.Add(new ScheduleAssignmentBindingModel
            {
                shiftId = shift.id,
                staffId = doctors.First().id,
                role = Roles.Doctor
            });
            assignments.Add(new ScheduleAssignmentBindingModel
            {
                shiftId = shift.id,
                staffId = nurses.First().id,
                role = Roles.Nurse
            });
            Console.WriteLine($"Добавлены назначения на смену {shift.startTime:HH:mm}-{shift.endTime:HH:mm}");
        }

        // Сначала создаём расписание без назначений
        var newSchedule = scheduleStorage.Insert(new ScheduleBindingModel
        {
            date = today,
            departmentId = dep.id
        });

        if (newSchedule != null)
        {
            // Присваиваем scheduleId всем назначениям
            foreach (var assignment in assignments)
            {
                assignment.scheduleId = newSchedule.id;
            }

            // Обновляем расписание, добавляя назначения
            var updatedSchedule = scheduleStorage.Update(new ScheduleBindingModel
            {
                id = newSchedule.id,
                date = today,
                departmentId = dep.id,
                assignments = assignments
            });

            Console.WriteLine($"Добавлено расписание на {today:dd.MM.yyyy} для департамента {dep.name}");
        }
    }
    else
    {
        Console.WriteLine($"Расписание на {today:dd.MM.yyyy} уже существует для {dep.name}");
    }

}

Console.WriteLine("Инициализация завершена.");
